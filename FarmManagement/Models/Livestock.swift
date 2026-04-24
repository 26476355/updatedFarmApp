import Foundation

struct Livestock: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: String
    var breed: String
    var count: Int
    var fieldId: UUID?
    var dateAcquired: Date
    var notes: String = ""
}
