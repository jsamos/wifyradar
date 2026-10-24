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

    func clearPending() {
        pendingListURI = nil
        isOpeningSharedList = false
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
            navigation.isOpeningSharedList = true
            navigation.pendingListURI = nil

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
                } else {
                    navigation.isOpeningSharedList = false
                }
            } catch {
                navigation.isOpeningSharedList = false
                print("Share accept failed: \(error)")
            }
        }
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
