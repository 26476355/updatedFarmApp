import Foundation

enum UserRole: String, Codable, CaseIterable {
    case admin, farmer, customer
}

struct AppUser: Identifiable, Codable {
    var id = UUID()
    var name: String
    var email: String
    var password: String
    var role: UserRole
    var subscription: SubscriptionTier = .free
    var monthlyScanCount: Int = 0
    var joinedDate: Date = Date()
}

struct MarketplaceItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var price: Double
    var category: ItemCategory
    var imageEmoji: String
    var stock: Int
}

enum ItemCategory: String, Codable, CaseIterable {
    case plant = "Plant"
    case animal = "Animal"

    var icon: String {
        switch self {
        case .plant: return "leaf.fill"
        case .animal: return "hare.fill"
        }
    }
}

struct CartEntry: Identifiable, Codable {
    var id = UUID()
    var item: MarketplaceItem
    var quantity: Int
}

struct Order: Identifiable, Codable {
    var id = UUID()
    var customerId: UUID
    var items: [CartEntry]
    var total: Double
    var status: OrderStatus
    var date: Date
    var paymentId: String
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case shipped = "Shipped"
    case outForDelivery = "Out for Delivery"
    case delivered = "Delivered"
    case cancelled = "Cancelled"

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .shipped: return "shippingbox"
        case .outForDelivery: return "truck.box"
        case .delivered: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle"
        }
    }

    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .shipped: return "purple"
        case .outForDelivery: return "cyan"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
}
