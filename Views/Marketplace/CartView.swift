import SwiftUI
import SafariServices

struct CustomerCartView: View {
    @EnvironmentObject var marketplace: MarketplaceStore
    @EnvironmentObject var auth: AuthService
    @State private var showPayPal = false
    @State private var orderPlaced = false
    @State private var placedOrder: Order?

    var body: some View {
        NavigationStack {
            Group {
                if marketplace.cart.isEmpty {
                    EmptyStateView(icon: "cart", title: "Cart is Empty", subtitle: "Browse the marketplace to add items")
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(marketplace.cart) { entry in
                                    cartRow(entry)
                                }
                            }
                            .padding()
                        }
                        checkoutBar
                    }
                }
            }
            .background(FarmTheme.background)
            .navigationTitle("My Cart")
            .toolbar {
                if !marketplace.cart.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") { marketplace.clearCart() }.foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showPayPal) {
                PayPalCheckoutView(amount: marketplace.cartTotal) { paymentId in
                    if let user = auth.currentUser {
                        placedOrder = marketplace.placeOrder(customerId: user.id, paymentId: paymentId)
                        orderPlaced = true
                    }
                }
            }
            .fullScreenCover(isPresented: $orderPlaced) {
                OrderConfirmationView(order: placedOrder)
            }
        }
    }

    private func cartRow(_ entry: CartEntry) -> some View {
        FarmCard {
            HStack(spacing: 12) {
                Text(entry.item.imageEmoji).font(.title)
                    .frame(width: 50, height: 50)
                    .background(FarmTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.item.name).fontWeight(.semibold).font(.subheadline)
                    Text("R\(entry.item.price, specifier: "%.0f") each")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()

                HStack(spacing: 10) {
                    Button { marketplace.updateQuantity(entry, quantity: entry.quantity - 1) } label: {
                        Image(systemName: entry.quantity == 1 ? "trash" : "minus")
                            .font(.caption2).frame(width: 26, height: 26)
                            .background(FarmTheme.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Text("\(entry.quantity)").fontWeight(.semibold).frame(minWidth: 20)
                    Button { marketplace.updateQuantity(entry, quantity: entry.quantity + 1) } label: {
                        Image(systemName: "plus")
                            .font(.caption2).foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(FarmTheme.primary).clipShape(Circle())
                    }
                }
            }
        }
    }

    private var checkoutBar: some View {
        VStack(spacing: 12) {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text("Total").font(.caption).foregroundColor(.secondary)
                    Text("R\(marketplace.cartTotal, specifier: "%.2f")")
                        .font(.title2).fontWeight(.bold)
                }
                Spacer()
                Button { showPayPal = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                        Text("Pay with PayPal")
                    }
                    .fontWeight(.bold).foregroundColor(.white)
                    .padding(.horizontal, 24).padding(.vertical, 14)
                    .background(Color(red: 0.0, green: 0.47, blue: 0.75))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal).padding(.bottom, 8)
        }
        .background(FarmTheme.card)
    }
}

struct PayPalCheckoutView: View {
    let amount: Double
    let onComplete: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "creditcard.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 0.0, green: 0.47, blue: 0.75))

                Text("PayPal Checkout").font(.title2).fontWeight(.bold)
                Text("Amount: R\(amount, specifier: "%.2f")")
                    .font(.title3).foregroundColor(.secondary)

                Text("In production, this opens the PayPal SDK.\nFor now, tap below to simulate payment.")
                    .font(.caption).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal)

                if isProcessing {
                    ProgressView("Processing payment...")
                } else {
                    Button {
                        isProcessing = true
                        // Simulate PayPal payment processing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let paymentId = "PAYPAL-\(UUID().uuidString.prefix(8))"
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onComplete(paymentId)
                            }
                        }
                    } label: {
                        Text("Confirm Payment")
                            .fontWeight(.bold).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color(red: 0.0, green: 0.47, blue: 0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

struct OrderConfirmationView: View {
    let order: Order?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(FarmTheme.primary.opacity(0.1)).frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64)).foregroundColor(FarmTheme.primary)
            }
            Text("Order Placed! 🎉").font(.title).fontWeight(.bold)
            if let order {
                Text("Order #\(order.id.uuidString.prefix(8))")
                    .font(.caption).foregroundColor(.secondary)
                Text("Payment: \(order.paymentId)")
                    .font(.caption2).foregroundColor(FarmTheme.subtle)
            }
            Text("You can track your delivery in the Orders tab.")
                .font(.subheadline).foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button { dismiss() } label: {
                Text("Continue Shopping")
                    .fontWeight(.bold).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(FarmTheme.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal).padding(.bottom, 32)
        }
    }
}
