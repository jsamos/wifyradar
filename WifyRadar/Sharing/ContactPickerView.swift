import Contacts
import ContactsUI
import UIKit

@MainActor
final class ContactPickerPresenter: NSObject, CNContactPickerDelegate {
    static let shared = ContactPickerPresenter()

    private var onSelect: ((CNContact) -> Void)?

    func present(onSelect: @escaping (CNContact) -> Void) {
        self.onSelect = onSelect

        let picker = CNContactPickerViewController()
        picker.delegate = self
        picker.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactOrganizationNameKey,
            CNContactEmailAddressesKey,
        ]
        picker.predicateForEnablingContact = NSPredicate(
            format: "emailAddresses.@count > 0"
        )
        picker.predicateForSelectionOfContact = NSPredicate(
            format: "emailAddresses.@count > 0"
        )

        guard let presenter = KeyWindowPresenter.topViewController() else { return }
        presenter.present(picker, animated: true)
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        onSelect = nil
    }

    func contactPicker(
        _ picker: CNContactPickerViewController,
        didSelect contact: CNContact
    ) {
        let selected = onSelect
        onSelect = nil
        selected?(contact)
    }
}
