import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject var marketplace: MarketplaceStore
    @State private var filter: ItemCategory?
    @State private var search = ""

    private var filtered: [MarketplaceItem] {
        marketplace.items.filter { item in
            (filter == nil || item.category == filter) &&
            (search.isEmpty || item.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    categoryFilter
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
                        ForEach(filtered) { item in
                            MarketplaceCard(item: item)
                        }
                    }
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Marketplace")
            .searchable(text: $search, prompt: "Search plants & animals...")
        }
    }

    private var categoryFilter: some View {
        HStack(spacing: 8) {
            FilterChip(label: "All", icon: "square.grid.2x2", selected: filter == nil) { filter = nil }
            FilterChip(label: "Plants", icon: "leaf.fill", selected: filter == .plant) { filter = .plant }
            FilterChip(label: "Animals", icon: "hare.fill", selected: filter == .animal) { filter = .animal }
            Spacer()
        }
    }
}

private struct FilterChip: View {
    let label: String
    let icon: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption2)
                Text(label).font(.caption).fontWeight(.medium)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .foregroundColor(selected ? .white : FarmTheme.primary)
            .background(selected ? FarmTheme.primary : FarmTheme.primary.opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

private struct MarketplaceCard: View {
    let item: MarketplaceItem
    @EnvironmentObject var marketplace: MarketplaceStore
    @State private var added = false

    var body: some View {
        VStack(spacing: 8) {
            Text(item.imageEmoji).font(.system(size: 44))
                .frame(maxWidth: .infinity).frame(height: 80)
                .background(FarmTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.name).font(.caption).fontWeight(.semibold)
                .lineLimit(1)
            Text(item.description).font(.caption2).foregroundColor(.secondary)
                .lineLimit(1)

            HStack {
                Text("R\(item.price, specifier: "%.0f")")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(FarmTheme.primary)
                Spacer()
                Button {
                    marketplace.addToCart(item)
                    withAnimation { added = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { added = false }
                } label: {
                    Image(systemName: added ? "checkmark" : "plus")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(added ? Color.green : FarmTheme.primary)
                        .clipShape(Circle())
                }
            }
        }
        .padding(12)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: FarmTheme.shadow, radius: 5, y: 2)
    }
}
