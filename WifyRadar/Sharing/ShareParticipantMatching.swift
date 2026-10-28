import CloudKit

struct ShareParticipantIdentity: Equatable {
    var userRecordName: String?
    var email: String?
}

enum ShareParticipantMatching {
    static func matches(_ a: ShareParticipantIdentity, _ b: ShareParticipantIdentity) -> Bool {
        if let left = a.userRecordName, let right = b.userRecordName, left == right {
            return true
        }
        let leftEmail = a.email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let rightEmail = b.email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        if !leftEmail.isEmpty, leftEmail == rightEmail {
            return true
        }
        return false
    }

    static func identity(for participant: CKShare.Participant) -> ShareParticipantIdentity {
        ShareParticipantIdentity(
            userRecordName: participant.userIdentity.userRecordID?.recordName,
            email: participant.userIdentity.lookupInfo?.emailAddress
        )
    }

    static func liveParticipant(
        matching candidate: CKShare.Participant,
        in share: CKShare
    ) -> CKShare.Participant? {
        let candidateIdentity = identity(for: candidate)
        return share.participants.first { live in
            guard live.role != .owner else { return false }
            return matches(candidateIdentity, identity(for: live))
        }
    }
}
