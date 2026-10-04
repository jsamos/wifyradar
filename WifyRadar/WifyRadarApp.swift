import SwiftData
import SwiftUI

@main
struct WifyRadarApp: App {
    var body: some Scene {
        WindowGroup {
            ListsHomeView()
        }
        .modelContainer(for: [SharedList.self, ListItem.self])
    }
}
