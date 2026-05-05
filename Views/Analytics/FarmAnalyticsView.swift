import SwiftUI

struct FarmAnalyticsView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var marketplace: MarketplaceStore
    @EnvironmentObject var auth: AuthService

    private var totalIncome: Double {
        store.transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    private var totalExpense: Double {
        store.transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    private var profit: Double { totalIncome - totalExpense }

    private var yieldPerField: [(field: Field, harvests: Int, totalYield: Double)] {
        store.fields.map { field in
            let fieldCrops = store.crops.filter { $0.fieldId == field.id }
            let cropIds = Set(fieldCrops.map { $0.id })
            let fieldHarvests = store.harvests.filter { cropIds.contains($0.cropId) }
            return (field, fieldHarvests.count, fieldHarvests.reduce(0) { $0 + $1.quantity })
        }.sorted { $0.totalYield > $1.totalYield }
    }

    private var cropPerformance: [(name: String, harvests: Int, yield: Double)] {
        let grouped = Dictionary(grouping: store.harvests, by: { $0.cropId })
        return grouped.compactMap { cropId, harvests in
            guard let crop = store.crops.first(where: { $0.id == cropId }) else { return nil }
            return (crop.name, harvests.count, harvests.reduce(0) { $0 + $1.quantity })
        }.sorted { $0.yield > $1.yield }
    }

    private var salesByCategory: [(category: String, total: Double)] {
        let delivered = marketplace.orders.filter { $0.status == .delivered }
        var catTotals: [String: Double] = [:]
        for order in delivered {
            for entry in order.items {
                let cat = entry.item.category.rawValue
                catTotals[cat, default: 0] += entry.item.price * Double(entry.quantity)
            }
        }
        return catTotals.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !auth.tier.hasAnalytics {
                        upgradePrompt
                    } else {
                        profitCard
                        revenueBreakdown
                        if !yieldPerField.isEmpty { fieldYieldSection }
                        if !cropPerformance.isEmpty { cropPerformanceSection }
                        if !salesByCategory.isEmpty { salesByCategorySection }
                        farmHealthScore
                    }
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Farm Analytics")
        }
    }

    private var profitCard: some View {
        VStack(spacing: 8) {
            Text("Net Profit").font(.caption).foregroundColor(.white.opacity(0.8))
            Text("R\(profit, specifier: "%.0f")")
                .font(.system(size: 36, weight: .bold)).foregroundColor(.white)
            HStack(spacing: 20) {
                VStack(spacing: 2) {
                    Text("R\(totalIncome, specifier: "%.0f")").font(.caption).fontWeight(.bold)
                    Text("Income").font(.caption2)
                }.foregroundColor(.white.opacity(0.9))
                VStack(spacing: 2) {
                    Text("R\(totalExpense, specifier: "%.0f")").font(.caption).fontWeight(.bold)
                    Text("Expenses").font(.caption2)
                }.foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity).padding(20)
        .background(profit >= 0 ? FarmTheme.gradient : LinearGradient(colors: [.red, .red.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var revenueBreakdown: some View {
        HStack(spacing: 10) {
            StatBadge(icon: "shippingbox.fill", value: "\(marketplace.orders.filter { $0.status == .delivered }.count)", label: "Sales", color: .green)
            StatBadge(icon: "clock", value: "\(marketplace.orders.filter { $0.status == .pending }.count)", label: "Pending", color: .orange)
            StatBadge(icon: "leaf.fill", value: "\(store.fields.count)", label: "Fields", color: FarmTheme.primary)
            StatBadge(icon: "chart.bar.fill", value: "\(store.harvests.count)", label: "Harvests", color: .purple)
        }
    }

    private var fieldYieldSection: some View {
        FarmCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill").foregroundColor(FarmTheme.primary)
                    Text("Yield per Field").font(.subheadline).fontWeight(.bold)
                }
                ForEach(yieldPerField, id: \.field.id) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.field.name).font(.caption).fontWeight(.semibold)
                            Text("\(entry.field.soilType) • \(entry.field.size, specifier: "%.1f") acres")
                                .font(.caption2).foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(entry.totalYield, specifier: "%.0f") kg").font(.caption).fontWeight(.bold).foregroundColor(FarmTheme.primary)
                            Text("\(entry.harvests) harvests").font(.caption2).foregroundColor(.secondary)
                        }
                    }
                    if entry.field.id != yieldPerField.last?.field.id { Divider() }
                }
            }
        }
    }

    private var cropPerformanceSection: some View {
        FarmCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "carrot.fill").foregroundColor(.orange)
                    Text("Top Crops by Yield").font(.subheadline).fontWeight(.bold)
                }
                ForEach(cropPerformance.prefix(5), id: \.name) { entry in
                    HStack {
                        Text(entry.name).font(.caption).fontWeight(.medium)
                        Spacer()
                        Text("\(entry.yield, specifier: "%.0f") kg").font(.caption).fontWeight(.bold).foregroundColor(.orange)
                    }
                }
            }
        }
    }

    private var salesByCategorySection: some View {
        FarmCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "banknote.fill").foregroundColor(.green)
                    Text("Sales by Category").font(.subheadline).fontWeight(.bold)
                }
                ForEach(salesByCategory, id: \.category) { entry in
                    HStack {
                        Text(entry.category).font(.caption).fontWeight(.medium)
                        Spacer()
                        Text("R\(entry.total, specifier: "%.0f")").font(.caption).fontWeight(.bold).foregroundColor(.green)
                    }
                }
            }
        }
    }

    private var farmHealthScore: some View {
        let score = calculateHealthScore()
        return FarmCard {
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill").foregroundColor(scoreColor(score))
                    Text("Farm Health Score").font(.subheadline).fontWeight(.bold)
                }
                Text("\(score)").font(.system(size: 44, weight: .bold)).foregroundColor(scoreColor(score))
                Text(scoreLabel(score)).font(.caption).foregroundColor(.secondary)
                healthTips(score)
            }
        }
    }

    private func calculateHealthScore() -> Int {
        var score = 50
        if !store.fields.isEmpty { score += 10 }
        if !store.crops.isEmpty { score += 10 }
        if !store.harvests.isEmpty { score += 10 }
        if profit > 0 { score += 10 }
        if store.fields.count >= 3 { score += 5 }
        if store.harvests.count >= 5 { score += 5 }
        return min(score, 100)
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }

    private func scoreLabel(_ score: Int) -> String {
        if score >= 80 { return "Excellent — your farm is thriving!" }
        if score >= 60 { return "Good — room for improvement" }
        return "Needs attention — add more data to improve"
    }

    @ViewBuilder
    private func healthTips(_ score: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if store.fields.isEmpty {
                tipRow("Add your first field to start tracking")
            }
            if store.harvests.isEmpty {
                tipRow("Record harvests to track yield performance")
            }
            if profit <= 0 && !store.transactions.isEmpty {
                tipRow("Expenses exceed income — review costs")
            }
        }
    }

    private func tipRow(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.right.circle.fill").font(.caption2).foregroundColor(.orange)
            Text(text).font(.caption2).foregroundColor(.secondary)
        }
    }

    private var upgradePrompt: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().fill(Color.purple.opacity(0.08)).frame(width: 120, height: 120)
                Image(systemName: "chart.bar.xaxis").font(.system(size: 48)).foregroundColor(.purple)
            }
            Text("Know your numbers").font(.title3).fontWeight(.black)
            Text("Which field yields the most? Which crop makes the most money?\nFarm Analytics turns your data into decisions.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                .padding(.horizontal, 24).lineSpacing(4)
            NavigationLink(destination: SubscriptionView()) {
                Text("Unlock Analytics \u{2192}")
                    .fontWeight(.black).foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 14)
                    .background(FarmTheme.gradient).clipShape(Capsule())
            }
            Spacer()
        }
    }
}
