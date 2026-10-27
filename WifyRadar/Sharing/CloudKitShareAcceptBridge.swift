import CloudKit
import CoreData
import Observation
import UIKit

@Observable
@MainActor
final class ShareNavigationStore {
    static let shared = ShareNavigationStore()

    var isOpeningSharedList = false
    var pendingListURI: URL?
    var acceptErrorMessage: String?
    var pendingAcceptMetadata: CKShare.Metadata?
    var ownerNoticeMessage: String?
    var pendingOwnerListURI: URL?

    func clearPending() {
        pendingListURI = nil
        isOpeningSharedList = false
        clearAcceptFailure()
    }

    func clearAcceptFailure() {
        acceptErrorMessage = nil
        pendingAcceptMetadata = nil
    }

    func clearOwnerNotice() {
        ownerNoticeMessage = nil
        pendingOwnerListURI = nil
    }
}

final class CloudKitShareAcceptBridge: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = CloudKitShareSceneDelegate.self
        return configuration
    }

    func application(
        _ application: UIApplication,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        ShareAcceptance.handle(cloudKitShareMetadata)
    }
}

final class CloudKitShareSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let metadata = connectionOptions.cloudKitShareMetadata {
            ShareAcceptance.handle(metadata)
        }
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        ShareAcceptance.handle(cloudKitShareMetadata)
    }
}

enum ShareAcceptance {
    @MainActor
    static func handle(_ metadata: CKShare.Metadata) {
        Task {
            let navigation = ShareNavigationStore.shared
            navigation.acceptErrorMessage = nil
            navigation.ownerNoticeMessage = nil
            navigation.pendingAcceptMetadata = metadata
            navigation.isOpeningSharedList = true
            navigation.pendingListURI = nil

            if metadata.participantRole == .owner {
                await openExistingOwnedList(metadata: metadata)
                return
            }

            var attempts = 0
            while PersistenceController.shared.sharedStore == nil, attempts < 50 {
                attempts += 1
                try? await Task.sleep(for: .milliseconds(100))
            }

            let context = PersistenceController.shared.viewContext
            let before = Set((try? context.fetch(SharedList.fetchRequest()))?.map(\.objectID) ?? [])

            do {
                try await PersistenceController.shared.acceptShare(metadata: metadata)

                for _ in 0..<40 {
                    context.refreshAllObjects()
                    let lists = try context.fetch(SharedList.fetchRequest())
                    if let opened = Self.resolveOpenedList(
                        metadata: metadata,
                        lists: lists,
                        before: before
                    ) {
                        navigation.pendingListURI = opened.objectID.uriRepresentation()
                        navigation.pendingAcceptMetadata = nil
                        return
                    }
                    try? await Task.sleep(for: .milliseconds(250))
                }

                context.refreshAllObjects()
                let lists = try context.fetch(SharedList.fetchRequest())
                if let opened = Self.resolveOpenedList(
                    metadata: metadata,
                    lists: lists,
                    before: before
                ) {
                    navigation.pendingListURI = opened.objectID.uriRepresentation()
                    navigation.pendingAcceptMetadata = nil
                } else {
                    navigation.pendingAcceptMetadata = metadata
                    navigation.acceptErrorMessage =
                        "The shared list didn’t appear. Check your connection and try again."
                }
            } catch {
                navigation.pendingAcceptMetadata = metadata
                navigation.acceptErrorMessage = error.localizedDescription
            }
        }
    }

    @MainActor
    private static func openExistingOwnedList(metadata: CKShare.Metadata) async {
        let navigation = ShareNavigationStore.shared
        let persistence = PersistenceController.shared

        var attempts = 0
        while persistence.privateStore == nil, attempts < 50 {
            attempts += 1
            try? await Task.sleep(for: .milliseconds(100))
        }

        let context = persistence.viewContext
        context.refreshAllObjects()
        let lists = (try? context.fetch(SharedList.fetchRequest())) ?? []

        if let opened = resolveOwnedList(metadata: metadata, lists: lists) {
            let listURI = opened.objectID.uriRepresentation()
            navigation.pendingAcceptMetadata = nil
            navigation.isOpeningSharedList = false
            try? await Task.sleep(for: .milliseconds(300))
            navigation.pendingOwnerListURI = listURI
            navigation.ownerNoticeMessage = "You’re already the owner of this list."
            return
        }

        navigation.pendingAcceptMetadata = nil
        navigation.acceptErrorMessage =
            "Couldn’t find this list on this phone. Open it from Lists if it’s already there."
    }

    @MainActor
    private static func resolveOwnedList(
        metadata: CKShare.Metadata,
        lists: [SharedList]
    ) -> SharedList? {
        resolveOpenedList(metadata: metadata, lists: lists, before: [])
    }

    @MainActor
    private static func resolveOpenedList(
        metadata: CKShare.Metadata,
        lists: [SharedList],
        before: Set<NSManagedObjectID>
    ) -> SharedList? {
        let persistence = PersistenceController.shared
        if let rootRecordID = metadata.hierarchicalRootRecordID {
            for list in lists {
                if let recordID = try? persistence.container.recordID(for: list.objectID),
                   recordID == rootRecordID {
                    return list
                }
            }
        }

        let newcomers = lists.filter { !before.contains($0.objectID) }
        return newcomers.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }.first
    }
}
