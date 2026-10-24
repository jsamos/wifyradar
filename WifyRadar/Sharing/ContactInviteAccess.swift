import Contacts

protocol ContactAuthorizationProviding: Sendable {
    func authorizationStatus() -> CNAuthorizationStatus
    func requestAccess() async -> CNAuthorizationStatus
}

struct SystemContactAuthorizationProvider: ContactAuthorizationProviding {
    func authorizationStatus() -> CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }

    func requestAccess() async -> CNAuthorizationStatus {
        let store = CNContactStore()
        _ = try? await store.requestAccess(for: .contacts)
        return authorizationStatus()
    }
}

enum ContactInviteAccessOutcome: Equatable {
    case presentContactPicker
    case keepTypedEmailOnly
}

enum ContactInviteAccess {
    static func canSelectContacts(_ status: CNAuthorizationStatus) -> Bool {
        switch status {
        case .authorized, .limited:
            return true
        default:
            return false
        }
    }

    static func outcome(for status: CNAuthorizationStatus) -> ContactInviteAccessOutcome {
        canSelectContacts(status) ? .presentContactPicker : .keepTypedEmailOnly
    }

    static func resolveAccess(
        using provider: any ContactAuthorizationProviding = SystemContactAuthorizationProvider()
    ) async -> ContactInviteAccessOutcome {
        var status = provider.authorizationStatus()
        if status == .notDetermined {
            status = await provider.requestAccess()
        }
        return outcome(for: status)
    }
}
