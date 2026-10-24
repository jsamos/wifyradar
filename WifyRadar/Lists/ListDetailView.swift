import CloudKit
import CoreData
import SwiftUI

struct ListDetailView: View {
    @ObservedObject var list: SharedList
    @Environment(\.managedObjectContext) private var context
    private let persistence = PersistenceController.shared

    @State private var newItemTitle = ""
    @State private var isShowingShareSheet = false
    @State private var inviteEmail = ""
    @State private var isInviting = false
    @State private var shareErrorMessage: String?
    @State private var inviteURL: URL?
    @State private var isShowingInviteLink = false

    private var sortedItems: [ListItem] {
        let items = (list.items as? Set<ListItem>) ?? []
        return items.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
    }

    private var canManageShare: Bool {
        persistence.isInPrivateStore(list)
    }

    var body: some View {
        List {
            Section {
                ForEach(sortedItems, id: \.objectID) { item in
                    HStack {
                        Button {
                            item.isChecked.toggle()
                            persistence.save()
                        } label: {
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isChecked ? Color.accentColor : .secondary)
                                .accessibilityLabel(item.isChecked ? "Marked done" : "Not done")
                        }
                        .buttonStyle(.plain)

                        Text(item.title ?? "")
                            .strikethrough(item.isChecked)
                            .foregroundStyle(item.isChecked ? .secondary : .primary)
                    }
                }
                .onDelete(perform: deleteItems)
            }

            Section {
                HStack {
                    TextField("New item", text: $newItemTitle)
                        .textInputAutocapitalization(.sentences)
                        .onSubmit(addItem)

                    Button("Add", action: addItem)
                        .disabled(newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationTitle(list.name ?? "List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if canManageShare {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Their Apple ID email", text: $inviteEmail)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                    } footer: {
                        Text("Invite-only. Enter the Apple ID email used on the other phone.")
                    }

                    Section {
                        Button {
                            Task { await sendInvite() }
                        } label: {
                            if isInviting {
                                ProgressView()
                            } else {
                                Text("Send Invite")
                            }
                        }
                        .disabled(
                            isInviting
                                || inviteEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )

                        Button("Manage Sharing…") {
                            Task { await openSystemSharing() }
                        }
                    }
                }
                .navigationTitle("Share List")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            isShowingShareSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isShowingInviteLink) {
            if let inviteURL {
                NavigationStack {
                    ShareLink(item: inviteURL) {
                        Label("Send Invite Link", systemImage: "square.and.arrow.up")
                    }
                    .padding()
                    .navigationTitle("Invite Ready")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                isShowingInviteLink = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .alert("Couldn’t share list", isPresented: Binding(
            get: { shareErrorMessage != nil },
            set: { if !$0 { shareErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { shareErrorMessage = nil }
        } message: {
            Text(shareErrorMessage ?? "")
        }
    }

    private func addItem() {
        let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let item = ListItem(context: context)
        item.title = title
        item.isChecked = false
        item.createdAt = Date()
        item.list = list
        persistence.save()
        newItemTitle = ""
    }

    private func deleteItems(at offsets: IndexSet) {
        let items = sortedItems
        for index in offsets {
            context.delete(items[index])
        }
        persistence.save()
    }

    private func sendInvite() async {
        isInviting = true
        defer { isInviting = false }
        do {
            persistence.save()
            let url = try await persistence.invite(emailAddress: inviteEmail, to: list)
            inviteURL = url
            isShowingShareSheet = false
            isShowingInviteLink = true
        } catch {
            shareErrorMessage = error.localizedDescription
        }
    }

    private func openSystemSharing() async {
        do {
            persistence.save()
            let prepared = try await persistence.share(list)
            isShowingShareSheet = false
            CloudSharingCoordinator.shared.present(
                share: prepared,
                container: persistence.ckContainer
            )
        } catch {
            shareErrorMessage = error.localizedDescription
        }
    }
}
