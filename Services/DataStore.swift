import Foundation

class DataStore: ObservableObject {
    @Published var fields: [Field] = []
    @Published var crops: [Crop] = []
    @Published var livestock: [Livestock] = []
    @Published var harvests: [Harvest] = []
    @Published var transactions: [Transaction] = []

    private let saveKey = "FarmData"

    init() { load() }

    // MARK: - Fields
    func addField(_ field: Field) { fields.append(field); save() }
    func deleteField(_ field: Field) { fields.removeAll { $0.id == field.id }; save() }
    func updateField(_ field: Field) {
        if let i = fields.firstIndex(where: { $0.id == field.id }) { fields[i] = field; save() }
    }

    // MARK: - Crops
    func addCrop(_ crop: Crop) { crops.append(crop); save() }
    func deleteCrop(_ crop: Crop) { crops.removeAll { $0.id == crop.id }; save() }
    func updateCrop(_ crop: Crop) {
        if let i = crops.firstIndex(where: { $0.id == crop.id }) { crops[i] = crop; save() }
    }

    // MARK: - Livestock
    func addLivestock(_ item: Livestock) { livestock.append(item); save() }
    func deleteLivestock(_ item: Livestock) { livestock.removeAll { $0.id == item.id }; save() }
    func updateLivestock(_ item: Livestock) {
        if let i = livestock.firstIndex(where: { $0.id == item.id }) { livestock[i] = item; save() }
    }

    // MARK: - Harvests
    func addHarvest(_ harvest: Harvest) { harvests.append(harvest); save() }
    func deleteHarvest(_ harvest: Harvest) { harvests.removeAll { $0.id == harvest.id }; save() }

    // MARK: - Transactions
    func addTransaction(_ t: Transaction) { transactions.append(t); save() }
    func deleteTransaction(_ t: Transaction) { transactions.removeAll { $0.id == t.id }; save() }

    // MARK: - Persistence (JSON file-based; swap for PostgreSQL later)
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("farm_data.json")
    }

    private func save() {
        let data = FarmData(fields: fields, crops: crops, livestock: livestock, harvests: harvests, transactions: transactions)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(FarmData.self, from: data) else { return }
        fields = decoded.fields
        crops = decoded.crops
        livestock = decoded.livestock
        harvests = decoded.harvests
        transactions = decoded.transactions
    }
}

private struct FarmData: Codable {
    let fields: [Field]
    let crops: [Crop]
    let livestock: [Livestock]
    let harvests: [Harvest]
    let transactions: [Transaction]
}
