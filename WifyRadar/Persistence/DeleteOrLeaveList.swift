import CloudKit
import CoreData

enum DeleteOrLeaveList {
    enum Ownership {
        case owned
        case shared(zoneID: CKRecordZone.ID, store: NSPersistentStore)
    }

    static func perform(
        list: SharedList,
        ownership: Ownership,
        purger: any SharedZonePurging,
        save: () throws -> Void
    ) async throws {
        switch ownership {
        case .owned:
            guard let context = list.managedObjectContext else {
                throw PersistenceError.missingPrivateStore
            }
            context.delete(list)
            try save()
        case .shared(let zoneID, let store):
            try await purger.purgeObjectsAndRecords(inZone: zoneID, store: store)
        }
    }
}
