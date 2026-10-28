import CloudKit
import CoreData

protocol SharedZonePurging: Sendable {
    func purgeObjectsAndRecords(
        inZone zoneID: CKRecordZone.ID,
        store: NSPersistentStore?
    ) async throws
}

struct CloudKitSharedZonePurger: SharedZonePurging, @unchecked Sendable {
    let container: NSPersistentCloudKitContainer

    func purgeObjectsAndRecords(
        inZone zoneID: CKRecordZone.ID,
        store: NSPersistentStore?
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.purgeObjectsAndRecordsInZone(with: zoneID, in: store) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
