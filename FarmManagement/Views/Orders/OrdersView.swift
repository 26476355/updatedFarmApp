import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var marketplace: MarketplaceStore
    @EnvironmentObject var auth: AuthService

    private var myOrders: [Order] {
        guard let user = auth.currentUser else { return [] }
        return marketplace.ordersFor(customerId: user.id)
    }

    var body: some View {
        NavigationStack {
            Group {
                if myOrders.isEmpty {
                    EmptyStateView(icon: "shippingbox", title: "No Orders Yet", subtitle: "Your orders will appear here")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(myOrders) { order in
                                orderCard(order)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(FarmTheme.background)
            .navigationTitle("My Orders")
        }
    }

    private func orderCard(_ order: Order) -> some View {
        FarmCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Order #\(order.id.uuidString.prefix(8))")
                        .font(.caption).fontWeight(.semibold)
                    Spacer()
                    Text(order.date, style: .date)
                        .font(.caption2).foregroundColor(FarmTheme.subtle)
                }

                statusTracker(order.status)

                Divider()

                ForEach(order.items) { entry in
                    HStack(spacing: 8) {
                        Text(entry.item.imageEmoji)
                        Text(entry.item.name).font(.caption)
                        Spacer()
                        Text("×\(entry.quantity)").font(.caption2).foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Total").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("R\(order.total, specifier: "%.2f")")
                        .fontWeight(.bold).foregroundColor(FarmTheme.primary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "creditcard").font(.caption2)
                    Text(order.paymentId).font(.caption2)
                }
                .foregroundColor(FarmTheme.subtle)
            }
        }
    }

    private func statusTracker(_ current: OrderStatus) -> some View {
        let steps: [OrderStatus] = [.pending, .confirmed, .shipped, .outForDelivery, .delivered]
        let currentIndex = steps.firstIndex(of: current) ?? 0

        return VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    if index > 0 {
                        Rectangle()
                            .fill(index <= currentIndex ? FarmTheme.primary : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                    Circle()
                        .fill(index <= currentIndex ? FarmTheme.primary : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .overlay {
                            if index == currentIndex {
                                Circle().stroke(FarmTheme.primary, lineWidth: 2)
                                    .frame(width: 18, height: 18)
                            }
                        }
                }
            }
            HStack {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Text(step.rawValue)
                        .font(.system(size: 7))
                        .foregroundColor(index <= currentIndex ? FarmTheme.primary : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
