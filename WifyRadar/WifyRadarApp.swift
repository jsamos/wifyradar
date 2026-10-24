import SwiftUI

@main
struct WifyRadarApp: App {
    @UIApplicationDelegateAdaptor(CloudKitShareAcceptBridge.self) private var shareAcceptBridge
    private let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ListsHomeView()
                .environment(\.managedObjectContext, persistence.viewContext)
        }
    }
}
