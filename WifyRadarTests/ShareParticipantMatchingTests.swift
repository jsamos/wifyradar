import Testing
@testable import WifyRadar

struct ShareParticipantMatchingTests {
    @Test("matching user record names select the same person")
    func matchingRecordNames() {
        // Scenario: Owner removes a person (identity match)
        let left = ShareParticipantIdentity(userRecordName: "abc", email: nil)
        let right = ShareParticipantIdentity(userRecordName: "abc", email: "x@icloud.com")
        #expect(ShareParticipantMatching.matches(left, right))
    }

    @Test("matching emails select the same person when record ids differ")
    func matchingEmails() {
        let left = ShareParticipantIdentity(userRecordName: "a", email: " Partner@iCloud.com ")
        let right = ShareParticipantIdentity(userRecordName: "b", email: "partner@icloud.com")
        #expect(ShareParticipantMatching.matches(left, right))
    }

    @Test("different people do not match")
    func differentPeopleDoNotMatch() {
        let left = ShareParticipantIdentity(userRecordName: "a", email: "a@icloud.com")
        let right = ShareParticipantIdentity(userRecordName: "b", email: "b@icloud.com")
        #expect(!ShareParticipantMatching.matches(left, right))
    }
}
