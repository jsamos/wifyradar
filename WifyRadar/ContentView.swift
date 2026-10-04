import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.12, blue: 0.16),
                    Color(red: 0.12, green: 0.22, blue: 0.28),
                    Color(red: 0.18, green: 0.32, blue: 0.30),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("wifyradar")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(-0.5)

                Text("Shared lists, close by.")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(32)
        }
    }
}

#Preview {
    ContentView()
}
