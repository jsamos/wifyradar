import SwiftUI

struct ShareInviteLoadingView: View {
    private let shareNavigation = ShareNavigationStore.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var markAppeared = false

    private var isFailure: Bool {
        shareNavigation.acceptErrorMessage != nil
    }

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

                Image(systemName: isFailure ? "exclamationmark.triangle" : "list.bullet.rectangle")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(isFailure ? Color.orange : Color.accentColor)
                    .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion && !isFailure)
                    .opacity(markAppeared ? 1 : 0)
                    .scaleEffect(markAppeared ? 1 : 0.92)

                VStack(spacing: 10) {
                    Text("wifyradar")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.primary)

                    if isFailure {
                        Text("Couldn’t open this share")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        Text(shareNavigation.acceptErrorMessage ?? "")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("finding list")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                if isFailure {
                    VStack(spacing: 12) {
                        if shareNavigation.pendingAcceptMetadata != nil {
                            Button("Retry") {
                                guard let metadata = shareNavigation.pendingAcceptMetadata else { return }
                                shareNavigation.acceptErrorMessage = nil
                                ShareAcceptance.handle(metadata)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        Button("Go to Lists") {
                            shareNavigation.clearPending()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                } else {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(Color.accentColor)
                        .padding(.top, 8)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                isFailure
                    ? "wifyradar. Couldn’t open this share"
                    : "wifyradar. Finding list"
            )
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
