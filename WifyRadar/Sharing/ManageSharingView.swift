import CloudKit
import SwiftUI

struct ManageSharingView: View {
    let list: SharedList
    var onError: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    private let persistence = PersistenceController.shared

    @State private var participants: [CKShare.Participant] = []
    @State private var isLoading = true
    @State private var isWorking = false
    @State private var confirmStopSharing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading sharing…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section("People with access") {
                            if participants.isEmpty {
                                Text("No one else has access.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(Array(participants.enumerated()), id: \.offset) { _, participant in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(Self.primaryLabel(for: participant))
                                                .foregroundStyle(.primary)
                                            if let email = Self.emailAddress(for: participant),
                                               Self.formattedName(for: participant) != nil {
                                                Text(email)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Text(Self.statusLabel(for: participant))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Button("Remove", role: .destructive) {
                                            Task { await remove(participant) }
                                        }
                                        .disabled(isWorking)
                                    }
                                }
                            }
                        }

                        Section {
                            Button("Stop Sharing", role: .destructive) {
                                confirmStopSharing = true
                            }
                            .disabled(isWorking)
                        } footer: {
                            Text("Removes everyone’s access. Your list stays on this phone.")
                        }
                    }
                }
            }
            .navigationTitle("Manage Sharing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Stop sharing this list?",
                isPresented: $confirmStopSharing,
                titleVisibility: .visible
            ) {
                Button("Stop Sharing", role: .destructive) {
                    Task { await stopSharing() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Other people will lose access. Your copy of the list stays.")
            }
            .alert("Couldn’t update sharing", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .task {
                await reload()
            }
        }
    }

    private func reload() async {
        isLoading = true
        defer { isLoading = false }
        do {
            guard try persistence.existingShare(for: list) != nil else {
                throw PersistenceError.missingShare
            }
            participants = try persistence.participants(for: list)
        } catch {
            onError(error.localizedDescription)
            dismiss()
        }
    }

    private func remove(_ participant: CKShare.Participant) async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await persistence.removeParticipant(participant, from: list)
            participants = try persistence.participants(for: list)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stopSharing() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await persistence.stopSharing(list)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func formattedName(for participant: CKShare.Participant) -> String? {
        guard let name = participant.userIdentity.nameComponents else { return nil }
        let formatted = PersonNameComponentsFormatter.localizedString(
            from: name,
            style: .default
        )
        return formatted.isEmpty ? nil : formatted
    }

    private static func emailAddress(for participant: CKShare.Participant) -> String? {
        guard let email = participant.userIdentity.lookupInfo?.emailAddress, !email.isEmpty else {
            return nil
        }
        return email
    }

    private static func primaryLabel(for participant: CKShare.Participant) -> String {
        if let name = formattedName(for: participant) {
            return name
        }
        if let email = emailAddress(for: participant) {
            return email
        }
        return "Participant"
    }

    private static func statusLabel(for participant: CKShare.Participant) -> String {
        switch participant.acceptanceStatus {
        case .accepted:
            return "Accepted"
        case .pending:
            return "Invite pending"
        case .removed:
            return "Removed"
        default:
            return "Invited"
        }
    }
}
