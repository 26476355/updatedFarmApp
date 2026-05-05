import Foundation

class MarketplaceStore: ObservableObject {
    @Published var items: [MarketplaceItem] = []
    @Published var cart: [CartEntry] = []
    @Published var orders: [Order] = []

    private let itemsKey = "farm_marketplace_items"
    private let ordersKey = "farm_orders"

    init() {
        loadItems()
        loadOrders()
        if items.isEmpty { seedItems() }
    }

    // MARK: - Cart
    func addToCart(_ item: MarketplaceItem) {
        if let i = cart.firstIndex(where: { $0.item.id == item.id }) {
            cart[i].quantity += 1
        } else {
            cart.append(CartEntry(item: item, quantity: 1))
        }
    }

    func removeFromCart(_ entry: CartEntry) {
        cart.removeAll { $0.id == entry.id }
    }

    func updateQuantity(_ entry: CartEntry, quantity: Int) {
        if let i = cart.firstIndex(where: { $0.id == entry.id }) {
            if quantity <= 0 { cart.remove(at: i) }
            else { cart[i].quantity = quantity }
        }
    }

    var cartTotal: Double {
        cart.reduce(0) { $0 + $1.item.price * Double($1.quantity) }
    }

    func clearCart() { cart = [] }

    // MARK: - Orders
    func placeOrder(customerId: UUID, paymentId: String) -> Order {
        let order = Order(customerId: customerId, items: cart, total: cartTotal,
                          status: .pending, date: Date(), paymentId: paymentId)
        orders.append(order)
        saveOrders()
        clearCart()
        return order
    }

    func updateOrderStatus(_ orderId: UUID, status: OrderStatus) {
        if let i = orders.firstIndex(where: { $0.id == orderId }) {
            orders[i].status = status
            saveOrders()
        }
    }

    func updateOrderStatus(_ orderId: UUID, status: OrderStatus, recordingIncomeIn store: DataStore) {
        guard let i = orders.firstIndex(where: { $0.id == orderId }) else { return }
        let previousStatus = orders[i].status
        orders[i].status = status
        saveOrders()

        if status == .delivered && previousStatus != .delivered {
            let order = orders[i]
            let itemNames = order.items.map { "\($0.item.name) ×\($0.quantity)" }.joined(separator: ", ")
            store.addTransaction(Transaction(
                type: .income,
                category: "Sale",
                amount: order.total,
                date: Date(),
                description: "Order #\(order.id.uuidString.prefix(8)): \(itemNames)"
            ))
        }
    }

    func ordersFor(customerId: UUID) -> [Order] {
        orders.filter { $0.customerId == customerId }.sorted { $0.date > $1.date }
    }

    // MARK: - Admin: Manage Items
    func addItem(_ item: MarketplaceItem) { items.append(item); saveItems() }
    func deleteItem(_ item: MarketplaceItem) { items.removeAll { $0.id == item.id }; saveItems() }
    func updateItem(_ item: MarketplaceItem) {
        if let i = items.firstIndex(where: { $0.id == item.id }) { items[i] = item; saveItems() }
    }

    // MARK: - Persistence
    private func saveItems() {
        if let d = try? JSONEncoder().encode(items) { UserDefaults.standard.set(d, forKey: itemsKey) }
    }
    private func loadItems() {
        guard let d = UserDefaults.standard.data(forKey: itemsKey),
              let decoded = try? JSONDecoder().decode([MarketplaceItem].self, from: d) else { return }
        items = decoded
    }
    private func saveOrders() {
        if let d = try? JSONEncoder().encode(orders) { UserDefaults.standard.set(d, forKey: ordersKey) }
    }
    private func loadOrders() {
        guard let d = UserDefaults.standard.data(forKey: ordersKey),
              let decoded = try? JSONDecoder().decode([Order].self, from: d) else { return }
        orders = decoded
    }

    private func seedItems() {
        items = [
            MarketplaceItem(name: "Tomato Seedlings", description: "Pack of 6 healthy seedlings", price: 45, category: .plant, imageEmoji: "🍅", stock: 50),
            MarketplaceItem(name: "Maize Seeds (5kg)", description: "High-yield hybrid maize", price: 180, category: .plant, imageEmoji: "🌽", stock: 30),
            MarketplaceItem(name: "Spinach Bundle", description: "Fresh organic spinach", price: 25, category: .plant, imageEmoji: "🥬", stock: 100),
            MarketplaceItem(name: "Fruit Tree (Mango)", description: "2-year grafted mango tree", price: 350, category: .plant, imageEmoji: "🥭", stock: 15),
            MarketplaceItem(name: "Sunflower Seeds (2kg)", description: "Ornamental & oil variety", price: 95, category: .plant, imageEmoji: "🌻", stock: 40),
            MarketplaceItem(name: "Layer Hen", description: "Point-of-lay Rhode Island Red", price: 150, category: .animal, imageEmoji: "🐔", stock: 25),
            MarketplaceItem(name: "Broiler Chicks (10)", description: "Day-old Ross 308 chicks", price: 120, category: .animal, imageEmoji: "🐣", stock: 60),
            MarketplaceItem(name: "Dairy Goat", description: "Saanen doe, 1 year old", price: 2500, category: .animal, imageEmoji: "🐐", stock: 8),
            MarketplaceItem(name: "Piglet (Weaner)", description: "Large White, 8 weeks", price: 800, category: .animal, imageEmoji: "🐷", stock: 12),
            MarketplaceItem(name: "Nguni Calf", description: "6-month heifer calf", price: 5500, category: .animal, imageEmoji: "🐄", stock: 5),
        ]
        saveItems()
    }
}
