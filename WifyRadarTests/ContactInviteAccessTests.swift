import Contacts
import Foundation
import Testing
@testable import WifyRadar

private final class RequestTrackingProvider: ContactAuthorizationProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var _status: CNAuthorizationStatus
    private let afterRequest: CNAuthorizationStatus
    private(set) var requestCount = 0

    init(status: CNAuthorizationStatus, afterRequest: CNAuthorizationStatus) {
        _status = status
        self.afterRequest = afterRequest
    }

    func authorizationStatus() -> CNAuthorizationStatus {
        lock.lock()
        defer { lock.unlock() }
        return _status
    }

    func requestAccess() async -> CNAuthorizationStatus {
        lock.lock()
        requestCount += 1
        _status = afterRequest
        let value = _status
        lock.unlock()
        return value
    }
}

struct ContactInviteAccessTests {
    @Test("authorized proceeds to contact picker")
    func authorizedPresentsPicker() {
        #expect(ContactInviteAccess.outcome(for: .authorized) == .presentContactPicker)
    }

    @Test("limited proceeds to contact picker")
    func limitedPresentsPicker() {
        #expect(ContactInviteAccess.outcome(for: .limited) == .presentContactPicker)
    }

    @Test("denied keeps typed email only")
    func deniedKeepsTypedEmail() async {
        // Scenario: Denied access keeps manual email entry
        let provider = RequestTrackingProvider(status: .denied, afterRequest: .denied)
        let outcome = await ContactInviteAccess.resolveAccess(using: provider)
        #expect(outcome == .keepTypedEmailOnly)
        #expect(provider.requestCount == 0)
    }

    @Test("restricted keeps typed email only")
    func restrictedKeepsTypedEmail() async {
        let provider = RequestTrackingProvider(status: .restricted, afterRequest: .restricted)
        let outcome = await ContactInviteAccess.resolveAccess(using: provider)
        #expect(outcome == .keepTypedEmailOnly)
        #expect(provider.requestCount == 0)
    }

    @Test("notDetermined requests access then proceeds when granted")
    func notDeterminedRequestsThenProceeds() async {
        // Scenario: First use requests Contacts access
        let provider = RequestTrackingProvider(
            status: .notDetermined,
            afterRequest: .authorized
        )
        let outcome = await ContactInviteAccess.resolveAccess(using: provider)
        #expect(provider.requestCount == 1)
        #expect(outcome == .presentContactPicker)
    }

    @Test("notDetermined requests access then keeps typed email when denied")
    func notDeterminedRequestsThenDenied() async {
        let provider = RequestTrackingProvider(
            status: .notDetermined,
            afterRequest: .denied
        )
        let outcome = await ContactInviteAccess.resolveAccess(using: provider)
        #expect(provider.requestCount == 1)
        #expect(outcome == .keepTypedEmailOnly)
    }
}
