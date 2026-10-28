import SwiftUI

@main
struct WifyRadarApp: App {
    @UIApplicationDelegateAdaptor(CloudKitShareAcceptBridge.self) private var shareAcceptBridge
    private let persistence = PersistenceController.shared
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ListsHomeView()
                    .environment(\.managedObjectContext, persistence.viewContext)
                    .tint(Brand.primary)

                if showSplash {
                    LaunchSplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(1100))
                withAnimation(.easeOut(duration: 0.35)) {
                    showSplash = false
                }
            }
        }
    }
}
