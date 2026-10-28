import CoreData
import Foundation
import Testing
@testable import WifyRadar

struct PersistentHistoryMergerTests {
    @Test("suppression toggles and nests")
    func suppressionToggles() throws {
        let stack = try HistoryTestStack()
        let merger = PersistentHistoryMerger(
            container: stack.container,
            defaults: stack.defaults,
            tokenKey: stack.tokenKey
        )

        #expect(!merger.isSuppressed)
        merger.beginSuppression()
        #expect(merger.isSuppressed)
        merger.beginSuppression()
        #expect(merger.isSuppressed)
        merger.endSuppression()
        #expect(merger.isSuppressed)
        merger.endSuppression()
        #expect(!merger.isSuppressed)
    }

    @Test("suppressed merge leaves the view context unchanged")
    func suppressedMergeDoesNotApply() throws {
        // Scenario: Owner removes a person (local history merge plumbing)
        let stack = try HistoryTestStack()
        let merger = PersistentHistoryMerger(
            container: stack.container,
            defaults: stack.defaults,
            tokenKey: stack.tokenKey
        )
        let viewContext = stack.container.viewContext

        merger.mergePersistentHistoryNow()
        let objectID = try stack.insertList(named: "Still visible while suppressed")
        merger.mergePersistentHistoryNow()
        let viewObject = try viewContext.existingObject(with: objectID)
        let tokenBeforeDelete = try #require(stack.defaults.data(forKey: stack.tokenKey))

        merger.beginSuppression()
        try stack.deleteList(objectID: objectID)
        merger.mergePersistentHistoryNow()
        #expect(!viewObject.isDeleted)
        #expect((viewObject as? SharedList)?.name == "Still visible while suppressed")
        #expect(stack.defaults.data(forKey: stack.tokenKey) == tokenBeforeDelete)
        merger.endSuppression()

        merger.mergePersistentHistoryNow()
        #expect(viewObject.isDeleted || viewContext.registeredObject(for: objectID) == nil)
        #expect(try stack.fetchListNames(in: viewContext).isEmpty)
    }

    @Test("merge advances the history token after a background insert")
    func mergeAppliesInserts() throws {
        // Scenario: Owner removes a person (local history merge plumbing)
        let stack = try HistoryTestStack()
        let merger = PersistentHistoryMerger(
            container: stack.container,
            defaults: stack.defaults,
            tokenKey: stack.tokenKey
        )

        merger.mergePersistentHistoryNow()
        #expect(stack.defaults.data(forKey: stack.tokenKey) == nil)

        try stack.insertList(named: "Shared groceries")
        merger.mergePersistentHistoryNow()

        #expect(stack.defaults.data(forKey: stack.tokenKey) != nil)
        #expect(try stack.fetchListNames(in: stack.container.viewContext) == ["Shared groceries"])
    }

    @Test("merge brings background deletes into the view context")
    func mergeAppliesDeletes() throws {
        // Scenario: Owner removes a person (local history merge plumbing)
        let stack = try HistoryTestStack()
        let merger = PersistentHistoryMerger(
            container: stack.container,
            defaults: stack.defaults,
            tokenKey: stack.tokenKey
        )
        let viewContext = stack.container.viewContext

        merger.mergePersistentHistoryNow()
        let objectID = try stack.insertList(named: "Revoked list")
        merger.mergePersistentHistoryNow()
        let viewObject = try viewContext.existingObject(with: objectID) as! SharedList
        #expect(viewObject.name == "Revoked list")

        try stack.deleteList(objectID: objectID)
        #expect(!viewObject.isDeleted)

        merger.mergePersistentHistoryNow()

        #expect(viewObject.isDeleted || viewContext.registeredObject(for: objectID) == nil)
        #expect(try stack.fetchListNames(in: viewContext).isEmpty)
    }

    @Test("merge is idempotent once the history token advances")
    func mergeIsIdempotent() throws {
        let stack = try HistoryTestStack()
        let merger = PersistentHistoryMerger(
            container: stack.container,
            defaults: stack.defaults,
            tokenKey: stack.tokenKey
        )

        merger.mergePersistentHistoryNow()
        try stack.insertList(named: "Once")
        merger.mergePersistentHistoryNow()
        let tokenAfterFirstMerge = stack.defaults.data(forKey: stack.tokenKey)
        merger.mergePersistentHistoryNow()

        #expect(stack.defaults.data(forKey: stack.tokenKey) == tokenAfterFirstMerge)
        #expect(try stack.fetchListNames(in: stack.container.viewContext) == ["Once"])
    }
}

private final class HistoryTestStack {
    let container: NSPersistentContainer
    let defaults: UserDefaults
    let tokenKey: String
    private let storeURL: URL
    private let suiteName: String

    init() throws {
        guard let model = NSManagedObjectModel.mergedModel(
            from: [Bundle(for: PersistenceController.self)]
        ) else {
            throw TestStackError.missingModel
        }

        let suiteName = "wifyradar.tests.history.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            throw TestStackError.missingDefaults
        }
        defaults.removePersistentDomain(forName: suiteName)

        storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("wifyradar-history-\(UUID().uuidString).sqlite")

        let description = NSPersistentStoreDescription(url: storeURL)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let container = NSPersistentContainer(name: "WifyRadarHistoryTest", managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError {
            throw loadError
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.transactionAuthor = "viewContext"

        self.container = container
        self.defaults = defaults
        self.suiteName = suiteName
        self.tokenKey = "token.\(suiteName)"
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + "-shm"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + "-wal"))
    }

    @discardableResult
    func insertList(named name: String) throws -> NSManagedObjectID {
        let context = container.newBackgroundContext()
        context.transactionAuthor = "backgroundWriter"
        var objectID: NSManagedObjectID!
        var saveError: Error?
        context.performAndWait {
            let list = SharedList(context: context)
            list.name = name
            list.createdAt = Date()
            do {
                try context.save()
                objectID = list.objectID
            } catch {
                saveError = error
            }
        }
        if let saveError {
            throw saveError
        }
        return objectID
    }

    func deleteList(objectID: NSManagedObjectID) throws {
        let context = container.newBackgroundContext()
        context.transactionAuthor = "backgroundWriter"
        var saveError: Error?
        context.performAndWait {
            do {
                let object = try context.existingObject(with: objectID)
                context.delete(object)
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let saveError {
            throw saveError
        }
    }

    func fetchListNames(in context: NSManagedObjectContext) throws -> [String] {
        var names: [String] = []
        var fetchError: Error?
        context.performAndWait {
            do {
                let request = SharedList.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \SharedList.name, ascending: true)]
                let lists = try context.fetch(request)
                names = lists.compactMap(\.name)
            } catch {
                fetchError = error
            }
        }
        if let fetchError {
            throw fetchError
        }
        return names
    }
}

private enum TestStackError: Error {
    case missingModel
    case missingDefaults
}
