import Testing
@testable import WifyRadar

struct ContactEmailSelectionTests {
    @Test("zero emails leaves the invite field unchanged")
    func zeroEmailsSelectsNone() {
        // Scenario: Contact with no usable emails
        let result = ContactEmailSelectionLogic.selection(from: [])
        #expect(result == .none)
    }

    @Test("blank emails are ignored as zero")
    func blankEmailsSelectsNone() {
        let result = ContactEmailSelectionLogic.selection(from: ["  ", ""])
        #expect(result == .none)
    }

    @Test("one email fills the invite field directly")
    func oneEmailFillsField() {
        // Scenario: Owner picks a contact email
        let result = ContactEmailSelectionLogic.selection(from: [" partner@icloud.com "])
        #expect(result == .fill("partner@icloud.com"))
    }

    @Test("many emails present choices")
    func manyEmailsPresentChoices() {
        // Scenario: Contact with multiple emails
        let result = ContactEmailSelectionLogic.selection(
            from: ["a@icloud.com", " b@gmail.com ", ""]
        )
        #expect(result == .choose(["a@icloud.com", "b@gmail.com"]))
    }
}
