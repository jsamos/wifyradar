import CoreData
import SwiftUI

struct ListsHomeView: View {
    @Environment(\.managedObjectContext) private var context
    private let persistence = PersistenceController.shared
    private let shareNavigation = ShareNavigationStore.shared
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SharedList.createdAt, ascending: false)],
        animation: .default
    )
    private var lists: FetchedResults<SharedList>

    @State private var path = NavigationPath()
    @State private var isCreatingList = false
    @State private var newListName = ""
    @State private var showOwnerNotice = false
    @State private var ownerListObjectID: NSManagedObjectID?
    @State private var pendingDeleteOrLeave: SharedList?
    @State private var pendingIsOwned = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if lists.isEmpty {
                    ContentUnavailableView {
                        Label("No lists yet", systemImage: "list.bullet.rectangle")
                    } description: {
                        Text("Create a list to get started.")
                    } actions: {
                        Button("Create List") {
                            isCreatingList = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(lists, id: \.objectID) { list in
                            NavigationLink(value: list.objectID) {
                                Text(list.name ?? "Untitled")
                            }
                        }
                        .onDelete(perform: requestDeleteOrLeave)
                    }
                }
            }
            .navigationTitle("wifyradar")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isCreatingList = true
                    } label: {
                        Label("Create List", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                if let list = try? context.existingObject(with: objectID) as? SharedList {
                    ListDetailView(list: list)
                }
            }
            .sheet(isPresented: $isCreatingList) {
                NavigationStack {
                    Form {
                        TextField("List name", text: $newListName)
                            .textInputAutocapitalization(.sentences)
                    }
                    .navigationTitle("New List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newListName = ""
                                isCreatingList = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                createList()
                            }
                            .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .task(id: shareNavigation.pendingListURI?.absoluteString) {
                openPendingSharedList(shareNavigation.pendingListURI)
            }
            .onChange(of: shareNavigation.ownerNoticeMessage) { _, message in
                guard message != nil else {
                    showOwnerNotice = false
                    return
                }
                if let uri = shareNavigation.pendingOwnerListURI,
                   let objectID = context.persistentStoreCoordinator?
                    .managedObjectID(forURIRepresentation: uri) {
                    ownerListObjectID = objectID
                } else {
                    ownerListObjectID = nil
                }
                showOwnerNotice = true
            }
            .alert("Already the owner", isPresented: $showOwnerNotice) {
                Button("OK") {
                    openOwnerListAfterOK()
                }
            } message: {
                Text(shareNavigation.ownerNoticeMessage ?? "You’re already the owner of this list.")
            }
            .confirmationDialog(
                pendingIsOwned ? "Delete this list?" : "Leave this list?",
                isPresented: Binding(
                    get: { pendingDeleteOrLeave != nil },
                    set: { if !$0 { pendingDeleteOrLeave = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(pendingIsOwned ? "Delete" : "Leave", role: .destructive) {
                    guard let list = pendingDeleteOrLeave else { return }
                    pendingDeleteOrLeave = nil
                    Task { await confirmDeleteOrLeave(list) }
                }
                Button("Cancel", role: .cancel) {
                    pendingDeleteOrLeave = nil
                }
            } message: {
                Text(
                    pendingIsOwned
                        ? "This permanently deletes the list. Anyone you shared it with will lose access."
                        : "You’ll leave this shared list. It won’t come back unless you’re invited again."
                )
            }
            .alert("Couldn’t update list", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .overlay {
            if shareNavigation.isOpeningSharedList {
                ShareInviteLoadingView()
                    .zIndex(1)
            }
        }
    }

    private func openPendingSharedList(_ uri: URL?) {
        guard let uri,
              shareNavigation.pendingListURI == uri,
              let objectID = context.persistentStoreCoordinator?
                .managedObjectID(forURIRepresentation: uri)
        else { return }
        shareNavigation.clearPending()
        path.append(objectID)
    }

    private func openOwnerListAfterOK() {
        let objectID = ownerListObjectID
        ownerListObjectID = nil
        shareNavigation.clearOwnerNotice()
        showOwnerNotice = false
        guard let objectID else { return }
        path.append(objectID)
    }

    private func createList() {
        let name = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let list = SharedList(context: context)
        list.name = name
        list.createdAt = Date()
        persistence.save()
        newListName = ""
        isCreatingList = false
    }

    private func requestDeleteOrLeave(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let list = lists[index]
        pendingIsOwned = persistence.isInPrivateStore(list)
        pendingDeleteOrLeave = list
    }

    private func confirmDeleteOrLeave(_ list: SharedList) async {
        do {
            try await persistence.deleteOrLeave(list)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
