import SwiftData
import SwiftUI

struct ListDetailView: View {
    @Bindable var list: SharedList
    @Environment(\.modelContext) private var modelContext
    @State private var newItemTitle = ""

    private var sortedItems: [ListItem] {
        (list.items ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        List {
            Section {
                ForEach(sortedItems) { item in
                    HStack {
                        Button {
                            item.isChecked.toggle()
                            try? modelContext.save()
                        } label: {
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isChecked ? Color.accentColor : .secondary)
                                .accessibilityLabel(item.isChecked ? "Marked done" : "Not done")
                        }
                        .buttonStyle(.plain)

                        Text(item.title)
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
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addItem() {
        let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let item = ListItem(title: title, list: list)
        modelContext.insert(item)
        try? modelContext.save()
        newItemTitle = ""
    }

    private func deleteItems(at offsets: IndexSet) {
        let items = sortedItems
        for index in offsets {
            modelContext.delete(items[index])
        }
        try? modelContext.save()
    }
}
