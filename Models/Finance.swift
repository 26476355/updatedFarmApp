import Foundation

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var type: TransactionType
    var category: String
    var amount: Double
    var date: Date
    var description: String
}

enum TransactionType: String, Codable, CaseIterable {
    case income, expense
}
