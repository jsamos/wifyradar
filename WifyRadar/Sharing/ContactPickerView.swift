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

        guard let presenter = Self.topViewController() else { return }
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

    private static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
