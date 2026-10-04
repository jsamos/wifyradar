import SwiftData
import SwiftUI

struct ListsHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SharedList.createdAt, order: .reverse) private var lists: [SharedList]
    @State private var isCreatingList = false
    @State private var newListName = ""

    var body: some View {
        NavigationStack {
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
                        ForEach(lists) { list in
                            NavigationLink(value: list) {
                                Text(list.name)
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
            .navigationDestination(for: SharedList.self) { list in
                ListDetailView(list: list)
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
        }
    }

    private func createList() {
        let name = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        modelContext.insert(SharedList(name: name))
        try? modelContext.save()
        newListName = ""
        isCreatingList = false
    }

    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(lists[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    ListsHomeView()
        .modelContainer(for: [SharedList.self, ListItem.self], inMemory: true)
}
