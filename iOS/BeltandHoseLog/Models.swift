import Foundation

struct ComponentLog: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String        // Component name
    var detail: String      // Condition
    var date: Date           // Replaced date
    var note: String = ""
}
