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
                        .onDelete(perform: deleteLists)
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

    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            context.delete(lists[index])
        }
        persistence.save()
    }
}
