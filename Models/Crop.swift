import Foundation

struct Crop: Identifiable, Codable {
    var id = UUID()
    var name: String
    var fieldId: UUID
    var plantedDate: Date
    var expectedHarvestDate: Date
    var status: CropStatus = .planted
    var notes: String = ""
}

enum CropStatus: String, Codable, CaseIterable {
    case planned, planted, growing, readyToHarvest, harvested
}
