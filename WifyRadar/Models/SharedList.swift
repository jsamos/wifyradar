import Foundation
import SwiftData

@Model
final class SharedList {
    var name: String = ""
    var createdAt: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \ListItem.list)
    var items: [ListItem]?

    init(name: String) {
        self.name = name
        self.createdAt = Date()
    }
}
