import SwiftUI

struct ShareInviteLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var markAppeared = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.22),
                    Color.clear,
                    Color.accentColor.opacity(0.08),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 28) {
                Spacer(minLength: 0)

                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                    .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                    .opacity(markAppeared ? 1 : 0)
                    .scaleEffect(markAppeared ? 1 : 0.92)

                VStack(spacing: 10) {
                    Text("wifyradar")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("finding list")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                ProgressView()
                    .controlSize(.regular)
                    .tint(Color.accentColor)
                    .padding(.top, 8)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("wifyradar. Finding list")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            if reduceMotion {
                markAppeared = true
            } else {
                withAnimation(.easeOut(duration: 0.35)) {
                    markAppeared = true
                }
            }
        }
    }
}
