import Foundation

struct Field: Identifiable, Codable {
    var id = UUID()
    var name: String
    var size: Double
    var soilType: String
    var location: String
    var notes: String = ""
    var createdAt = Date()
}
