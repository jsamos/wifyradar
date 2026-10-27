import CloudKit
import Contacts
import CoreData
import SwiftUI
import UIKit

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
    @State private var emailChoices: ContactEmailChoices?
    @State private var contactsAccessMessage: String?
    @State private var isShowingManageSharing = false
    @State private var canOpenManageSharing = false

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
            shareSheet
                .task {
                    canOpenManageSharing = persistence.hasPeopleWithAccess(for: list)
                }
        }
        .sheet(isPresented: $isShowingManageSharing) {
            ManageSharingView(list: list) { message in
                shareErrorMessage = message
            }
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
        .alert("Contacts Access", isPresented: Binding(
            get: { contactsAccessMessage != nil },
            set: { if !$0 { contactsAccessMessage = nil } }
        )) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                contactsAccessMessage = nil
            }
            Button("OK", role: .cancel) { contactsAccessMessage = nil }
        } message: {
            Text(contactsAccessMessage ?? "")
        }
    }

    private var shareSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Their Apple ID email", text: $inviteEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()

                    Button {
                        Task { await chooseFromContacts() }
                    } label: {
                        Label("Choose from Contacts", systemImage: "person.crop.circle")
                    }
                } footer: {
                    Text("Invite-only. Pick a contact or type the Apple ID email used on the other phone.")
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

                    if canOpenManageSharing {
                        Button("Manage Sharing…") {
                            isShowingShareSheet = false
                            isShowingManageSharing = true
                        }
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
        .sheet(item: $emailChoices) { choices in
            ContactEmailListSheet(
                contactName: choices.displayName,
                emails: choices.emails
            ) { email in
                inviteEmail = email
            }
        }
    }

    private func chooseFromContacts() async {
        switch await ContactInviteAccess.resolveAccess() {
        case .presentContactPicker:
            ContactPickerPresenter.shared.present { contact in
                handleSelectedContact(contact)
            }
        case .keepTypedEmailOnly:
            contactsAccessMessage =
                "Contacts access is off, so the address book isn’t available. You can enable it in Settings, or type the Apple ID email instead."
        }
    }

    private func handleSelectedContact(_ contact: CNContact) {
        let emails = contact.emailAddresses.map { $0.value as String }
        switch ContactEmailSelectionLogic.selection(from: emails) {
        case .none:
            break
        case .fill(let email):
            inviteEmail = email
        case .choose(let choices):
            emailChoices = ContactEmailChoices(
                displayName: Self.displayName(for: contact),
                emails: choices
            )
        }
    }

    private static func displayName(for contact: CNContact) -> String {
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        if let name = formatter.string(from: contact), !name.isEmpty {
            return name
        }
        return "Choose Email"
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

}

private struct ContactEmailChoices: Identifiable {
    let id = UUID()
    let displayName: String
    let emails: [String]
}
