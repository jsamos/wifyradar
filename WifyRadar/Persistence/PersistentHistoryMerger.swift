import CoreData
import Foundation
import os

/// Merges persistent-history transactions into the UI context after remote store changes
/// (including CloudKit imports). Prefer this over `refreshAllObjects()`.
final class PersistentHistoryMerger: @unchecked Sendable {
    private let container: NSPersistentContainer
    private let defaults: UserDefaults
    private let tokenKey: String
    private let historyQueue = DispatchQueue(label: "com.wifyradar.persistent-history", qos: .utility)
    private let lock = OSAllocatedUnfairLock(initialState: 0)

    init(
        container: NSPersistentContainer,
        defaults: UserDefaults = .standard,
        tokenKey: String = "wifyradar.persistentHistoryToken"
    ) {
        self.container = container
        self.defaults = defaults
        self.tokenKey = tokenKey
    }

    var isSuppressed: Bool {
        lock.withLock { $0 > 0 }
    }

    func beginSuppression() {
        lock.withLock { $0 += 1 }
    }

    func endSuppression() {
        lock.withLock { $0 -= 1 }
    }

    func scheduleMerge() {
        guard !isSuppressed else { return }
        historyQueue.async { [weak self] in
            self?.mergePersistentHistory()
        }
    }

    /// Synchronous merge for tests and callers that already own the timing.
    func mergePersistentHistoryNow() {
        mergePersistentHistory()
    }

    private func mergePersistentHistory() {
        guard !isSuppressed else { return }

        let background = container.newBackgroundContext()
        background.transactionAuthor = "persistentHistoryMerger"
        background.performAndWait {
            do {
                let token = self.loadToken()
                let request = NSPersistentHistoryChangeRequest.fetchHistory(after: token)
                guard let result = try background.execute(request) as? NSPersistentHistoryResult,
                      let transactions = result.result as? [NSPersistentHistoryTransaction],
                      !transactions.isEmpty
                else { return }

                var latestToken = token
                let notifications = transactions.compactMap { transaction -> Notification? in
                    latestToken = transaction.token
                    return transaction.objectIDNotification()
                }

                guard !notifications.isEmpty else {
                    self.saveToken(latestToken)
                    return
                }

                let viewContext = self.container.viewContext
                viewContext.performAndWait {
                    for notification in notifications {
                        viewContext.mergeChanges(fromContextDidSave: notification)
                    }
                }
                self.saveToken(latestToken)
            } catch {
                // History merge failures should not crash; next remote change retries.
            }
        }
    }

    private func loadToken() -> NSPersistentHistoryToken? {
        guard let data = defaults.data(forKey: tokenKey) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: NSPersistentHistoryToken.self,
            from: data
        )
    }

    private func saveToken(_ token: NSPersistentHistoryToken?) {
        guard let token else {
            defaults.removeObject(forKey: tokenKey)
            return
        }
        guard let data = try? NSKeyedArchiver.archivedData(
            withRootObject: token,
            requiringSecureCoding: true
        ) else { return }
        defaults.set(data, forKey: tokenKey)
    }
}
