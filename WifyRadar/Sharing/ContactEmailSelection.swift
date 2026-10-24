import Foundation

enum ContactEmailSelection: Equatable {
    case none
    case fill(String)
    case choose([String])
}

enum ContactEmailSelectionLogic {
    static func selection(from emails: [String]) -> ContactEmailSelection {
        let normalized = emails
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        switch normalized.count {
        case 0:
            return .none
        case 1:
            return .fill(normalized[0])
        default:
            return .choose(normalized)
        }
    }
}
