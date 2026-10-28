import SwiftUI

struct LaunchSplashView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("W")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(Brand.gradient)

                Text("wifyradar")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)

                Text("Stay synced. Stay happy")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("wifyradar. Stay synced. Stay happy")
    }
}
