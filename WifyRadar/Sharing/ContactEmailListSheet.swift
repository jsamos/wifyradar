import SwiftUI

struct ContactEmailListSheet: View {
    let contactName: String
    let emails: [String]
    var onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(emails, id: \.self) { email in
                Button {
                    onSelect(email)
                    dismiss()
                } label: {
                    Text(email)
                        .foregroundStyle(.primary)
                }
            }
            .navigationTitle(contactName.isEmpty ? "Choose Email" : contactName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
