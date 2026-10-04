import Foundation
import SwiftData

@Model
final class ListItem {
    var title: String = ""
    var isChecked: Bool = false
    var createdAt: Date = Date()
    var list: SharedList?

    init(title: String, list: SharedList? = nil) {
        self.title = title
        self.list = list
        self.createdAt = Date()
    }
}
