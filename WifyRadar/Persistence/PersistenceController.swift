import CloudKit
import CoreData

enum CloudKitConfig {
    static let containerIdentifier = "iCloud.com.wifyradar.app"
}

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer
    private(set) var privateStore: NSPersistentStore?
    private(set) var sharedStore: NSPersistentStore?

    var ckContainer: CKContainer {
        CKContainer(identifier: CloudKitConfig.containerIdentifier)
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "WifyRadar")

        guard let privateDescription = container.persistentStoreDescriptions.first else {
            fatalError("Missing default store description")
        }

        let baseURL = privateDescription.url?.deletingLastPathComponent()
        if inMemory {
            privateDescription.url = URL(fileURLWithPath: "/dev/null")
        } else if let baseURL {
            privateDescription.url = baseURL.appendingPathComponent("private.sqlite")
        }

        privateDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        privateDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: CloudKitConfig.containerIdentifier
        )

        let sharedDescription = privateDescription.copy() as! NSPersistentStoreDescription
        if inMemory {
            sharedDescription.url = URL(fileURLWithPath: "/dev/null")
        } else if let baseURL {
            sharedDescription.url = baseURL.appendingPathComponent("shared.sqlite")
        }
        let sharedOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: CloudKitConfig.containerIdentifier
        )
        sharedOptions.databaseScope = .shared
        sharedDescription.cloudKitContainerOptions = sharedOptions

        container.persistentStoreDescriptions = [privateDescription, sharedDescription]

        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Unresolved Core Data error: \(error)")
            }
            Task { @MainActor in
                if description.cloudKitContainerOptions?.databaseScope == .shared {
                    self.sharedStore = self.store(matching: description)
                } else {
                    self.privateStore = self.store(matching: description)
                }
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func store(matching description: NSPersistentStoreDescription) -> NSPersistentStore? {
        guard let url = description.url else { return nil }
        return container.persistentStoreCoordinator.persistentStores.first { $0.url == url }
    }

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        try? context.save()
    }

    func isInPrivateStore(_ object: NSManagedObject) -> Bool {
        guard let store = object.objectID.persistentStore, let privateStore else { return false }
        return store == privateStore
    }

    func existingShare(for object: NSManagedObject) throws -> CKShare? {
        try container.fetchShares(matching: [object.objectID])[object.objectID]
    }

    func share(_ list: SharedList) async throws -> CKShare {
        if let existing = try existingShare(for: list) {
            existing.publicPermission = .none
            return existing
        }
        let (_, share, _) = try await container.share([list], to: nil)
        share[CKShare.SystemFieldKey.title] = (list.name ?? "List") as CKRecordValue
        share.publicPermission = .none
        return share
    }

    func invite(emailAddress: String, to list: SharedList) async throws -> URL {
        let trimmed = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw PersistenceError.invalidInvitee
        }
        guard let privateStore else {
            throw PersistenceError.missingPrivateStore
        }

        let share = try await share(list)
        let participant = try await ckContainer.shareParticipant(forEmailAddress: trimmed)
        participant.permission = .readWrite
        participant.role = .privateUser
        share.addParticipant(participant)

        let saved = try await persistUpdatedShare(share, in: privateStore)
        guard let url = saved.url else {
            throw PersistenceError.missingShareURL
        }
        return url
    }

    func acceptShare(metadata: CKShare.Metadata) async throws {
        guard let sharedStore else {
            throw PersistenceError.missingSharedStore
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.acceptShareInvitations(from: [metadata], into: sharedStore) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func persistUpdatedShare(_ share: CKShare, in store: NSPersistentStore) async throws -> CKShare {
        try await withCheckedThrowingContinuation { continuation in
            container.persistUpdatedShare(share, in: store) { savedShare, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let savedShare {
                    continuation.resume(returning: savedShare)
                } else {
                    continuation.resume(throwing: PersistenceError.missingShareURL)
                }
            }
        }
    }
}

enum PersistenceError: Error {
    case missingSharedStore
    case missingPrivateStore
    case invalidInvitee
    case missingShareURL
}

extension PersistenceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingSharedStore:
            return "Shared store isn’t ready yet. Try again in a moment."
        case .missingPrivateStore:
            return "Private store isn’t ready yet. Try again in a moment."
        case .invalidInvitee:
            return "Enter the other person’s Apple ID email."
        case .missingShareURL:
            return "CloudKit didn’t return an invite link."
        }
    }
}
