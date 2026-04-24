import Foundation

struct Harvest: Identifiable, Codable {
    var id = UUID()
    var cropId: UUID
    var date: Date
    var quantity: Double
    var unit: String
    var quality: HarvestQuality = .good
    var notes: String = ""
}

enum HarvestQuality: String, Codable, CaseIterable {
    case poor, fair, good, excellent
}
