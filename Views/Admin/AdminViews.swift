import SwiftUI

struct AdminOrdersView: View {
    @EnvironmentObject var marketplace: MarketplaceStore
    @EnvironmentObject var store: DataStore

    private var totalSales: Double {
        marketplace.orders.filter { $0.status == .delivered }.reduce(0) { $0 + $1.total }
    }
    private var deliveredCount: Int {
        marketplace.orders.filter { $0.status == .delivered }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if marketplace.orders.isEmpty {
                        EmptyStateView(icon: "tray", title: "No Orders Yet", subtitle: "Customer orders will appear here")
                            .frame(minHeight: 400)
                    } else {
                        // Sales summary banner
                        HStack(spacing: 12) {
                            salesCard(icon: "banknote.fill", value: "R\(totalSales)", label: "Total Sales", color: .green)
                            salesCard(icon: "checkmark.seal.fill", value: "\(deliveredCount)", label: "Delivered", color: FarmTheme.primary)
                            salesCard(icon: "clock.fill", value: "\(marketplace.orders.filter { $0.status == .pending }.count)", label: "Pending", color: .orange)
                        }

                        // Orders
                        VStack(spacing: 12) {
                            ForEach(marketplace.orders.sorted(by: { $0.date > $1.date })) { order in
                                adminOrderCard(order)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Manage Orders")
        }
    }

    private func salesCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundColor(color)
            }
            Text(value).font(.system(size: 15, weight: .black, design: .rounded)).foregroundColor(.white)
            Text(label).font(.caption2).foregroundColor(FarmTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: FarmTheme.shadow, radius: 6, y: 2)
    }

    private func adminOrderCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Order #\(order.id.uuidString.prefix(8))")
                        .font(.caption).fontWeight(.bold).foregroundColor(FarmTheme.textSecondary)
                    Text(order.date, style: .date).font(.caption2).foregroundColor(FarmTheme.subtle)
                }
                Spacer()
                Text("R\(order.total, specifier: "%.2f")")
                    .font(.title3).fontWeight(.black).foregroundColor(FarmTheme.accent)
            }

            HStack(spacing: 6) {
                Image(systemName: order.status.icon).font(.caption)
                Text(order.status.rawValue).font(.caption).fontWeight(.bold)
            }
            .foregroundColor(statusColor(order.status))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(statusColor(order.status).opacity(0.1))
            .clipShape(Capsule())

            ForEach(order.items) { entry in
                HStack(spacing: 8) {
                    Text(entry.item.imageEmoji).font(.title3)
                    Text(entry.item.name).font(.caption).fontWeight(.medium).foregroundColor(.white)
                    Spacer()
                    Text("×\(entry.quantity)").font(.caption).fontWeight(.bold).foregroundColor(FarmTheme.textSecondary)
                }
            }

            HStack {
                Menu {
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        Button {
                            marketplace.updateOrderStatus(order.id, status: status, recordingIncomeIn: store)
                        } label: {
                            Label(status.rawValue, systemImage: status.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath").font(.caption2)
                        Text("Update Status").font(.caption).fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(FarmTheme.gradient)
                    .clipShape(Capsule())
                }

                Spacer()

                if order.status == .delivered {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").font(.caption2)
                        Text("Sale recorded").font(.caption2).fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: FarmTheme.shadow, radius: 8, y: 3)
    }

    private func statusColor(_ status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .shipped: return .purple
        case .outForDelivery: return .cyan
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

struct AdminListingsView: View {
    @EnvironmentObject var marketplace: MarketplaceStore
    @State private var showAdd = false
    @State private var itemToDelete: MarketplaceItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                if marketplace.items.isEmpty {
                    EmptyStateView(icon: "tag", title: "No Listings", subtitle: "Add your first product to the marketplace")
                        .frame(minHeight: 400)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(marketplace.items) { item in
                            listingCard(item)
                        }
                    }
                    .padding()
                }
            }
            .background(FarmTheme.background)
            .navigationTitle("Listings")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(FarmTheme.accent)
                }
            }
            .sheet(isPresented: $showAdd) { AddListingView() }
            .alert("Delete Item", isPresented: Binding(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) { itemToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete { marketplace.deleteItem(item) }
                    itemToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete \"\(itemToDelete?.name ?? "")\"? This cannot be undone.")
            }
        }
    }

    private func listingCard(_ item: MarketplaceItem) -> some View {
        HStack(spacing: 14) {
            Text(item.imageEmoji).font(.system(size: 36))
                .frame(width: 56, height: 56)
                .background(FarmTheme.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                HStack(spacing: 8) {
                    Text("R\(item.price, specifier: "%.0f")")
                        .font(.caption).fontWeight(.black).foregroundColor(FarmTheme.accent)
                    Text("•").foregroundColor(FarmTheme.textSecondary)
                    Text("Stock: \(item.stock)")
                        .font(.caption).foregroundColor(item.stock < 5 ? .red : FarmTheme.textSecondary)
                }
            }
            Spacer()
            Button(role: .destructive) { itemToDelete = item } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.title3).foregroundColor(.red.opacity(0.6))
            }
        }
        .padding(14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: FarmTheme.shadow, radius: 6, y: 2)
    }
}

struct AddListingView: View {
    @EnvironmentObject var marketplace: MarketplaceStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var stock = ""
    @State private var category: ItemCategory = .plant
    @State private var emoji = "🌱"

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price (R)", text: $price).keyboardType(.decimalPad)
                    TextField("Stock", text: $stock).keyboardType(.numberPad)
                    TextField("Emoji Icon", text: $emoji)
                }
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Add Listing")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        marketplace.addItem(MarketplaceItem(
                            name: name, description: description,
                            price: Double(price) ?? 0, category: category,
                            imageEmoji: emoji, stock: Int(stock) ?? 0
                        ))
                        dismiss()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                    .fontWeight(.bold).foregroundColor(FarmTheme.primary)
                }
            }
        }
    }
}
