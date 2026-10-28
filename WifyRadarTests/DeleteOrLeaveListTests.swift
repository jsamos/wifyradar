import CloudKit
import CoreData
import Foundation
import Testing
@testable import WifyRadar

struct DeleteOrLeaveListTests {
    @Test("owned delete removes the list and does not purge a zone")
    func ownedDeleteDoesNotPurgeZone() async throws {
        // Scenario: User deletes an owned list
        let stack = try DeleteOrLeaveTestStack()
        let purger = RecordingZonePurger()
        let list = try stack.insertList(named: "Groceries")

        try await DeleteOrLeaveList.perform(
            list: list,
            ownership: .owned,
            purger: purger
        ) {
            try stack.context.save()
        }

        #expect(purger.calls.isEmpty)
        #expect(try stack.fetchListNames().isEmpty)
    }

    @Test("shared leave purges the share zone once")
    func sharedLeavePurgesZone() async throws {
        // Scenario: Participant leaves a shared list
        let stack = try DeleteOrLeaveTestStack()
        let purger = RecordingZonePurger()
        let list = try stack.insertList(named: "Shared groceries")
        let zoneID = CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKCurrentUserDefaultName)

        try await DeleteOrLeaveList.perform(
            list: list,
            ownership: .shared(zoneID: zoneID, store: stack.store),
            purger: purger,
            save: {}
        )

        #expect(purger.calls.count == 1)
        #expect(purger.calls.first?.zoneID == zoneID)
        #expect(purger.calls.first?.store === stack.store)
        #expect(try stack.fetchListNames() == ["Shared groceries"])
    }

    @Test("purge failure surfaces an error")
    func purgeFailureSurfacesError() async throws {
        // Scenario: Leave or delete failure is visible
        let stack = try DeleteOrLeaveTestStack()
        let purger = RecordingZonePurger()
        purger.errorToThrow = ZonePurgeTestError.boom
        let list = try stack.insertList(named: "Shared groceries")
        let zoneID = CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKCurrentUserDefaultName)

        await #expect(throws: ZonePurgeTestError.boom) {
            try await DeleteOrLeaveList.perform(
                list: list,
                ownership: .shared(zoneID: zoneID, store: stack.store),
                purger: purger,
                save: {}
            )
        }

        #expect(purger.calls.count == 1)
        #expect(try stack.fetchListNames() == ["Shared groceries"])
    }
}

private enum ZonePurgeTestError: Error {
    case boom
}

private final class RecordingZonePurger: SharedZonePurging, @unchecked Sendable {
    struct Call {
        let zoneID: CKRecordZone.ID
        let store: NSPersistentStore?
    }

    private(set) var calls: [Call] = []
    var errorToThrow: (any Error)?

    func purgeObjectsAndRecords(
        inZone zoneID: CKRecordZone.ID,
        store: NSPersistentStore?
    ) async throws {
        calls.append(Call(zoneID: zoneID, store: store))
        if let errorToThrow {
            throw errorToThrow
        }
    }
}

private final class DeleteOrLeaveTestStack {
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    let store: NSPersistentStore
    private let storeURL: URL

    init() throws {
        guard let model = NSManagedObjectModel.mergedModel(
            from: [Bundle(for: PersistenceController.self)]
        ) else {
            throw DeleteOrLeaveTestStackError.missingModel
        }

        storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("wifyradar-delete-leave-\(UUID().uuidString).sqlite")

        let description = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: "WifyRadarDeleteLeaveTest", managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError {
            throw loadError
        }

        guard let store = container.persistentStoreCoordinator.persistentStores.first else {
            throw DeleteOrLeaveTestStackError.missingStore
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.container = container
        self.context = container.viewContext
        self.store = store
    }

    deinit {
        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + "-shm"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + "-wal"))
    }

    @discardableResult
    func insertList(named name: String) throws -> SharedList {
        let list = SharedList(context: context)
        list.name = name
        list.createdAt = Date()
        try context.save()
        return list
    }

    func fetchListNames() throws -> [String] {
        let request = SharedList.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SharedList.name, ascending: true)]
        return try context.fetch(request).compactMap(\.name)
    }
}

private enum DeleteOrLeaveTestStackError: Error {
    case missingModel
    case missingStore
}
