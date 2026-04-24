import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var weatherService: WeatherService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingBanner
                    statsRow
                    quickActions
                    recentActivity
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("My Farm")
        }
    }

    private var greetingBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text("Farm Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "sun.max.fill")
                .font(.system(size: 36))
                .foregroundColor(FarmTheme.accent)
        }
        .padding(20)
        .background(FarmTheme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning 🌅" }
        if hour < 17 { return "Good Afternoon ☀️" }
        return "Good Evening 🌙"
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatBadge(icon: "leaf", value: "\(store.fields.count)", label: "Fields")
            StatBadge(icon: "carrot", value: "\(store.crops.count)", label: "Crops", color: .orange)
            StatBadge(icon: "hare", value: "\(store.livestock.count)", label: "Livestock", color: .brown)
            StatBadge(icon: "shippingbox", value: "\(store.harvests.count)", label: "Harvests", color: .purple)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                QuickActionButton(icon: "plus.circle.fill", label: "Add Field", color: FarmTheme.primary)
                QuickActionButton(icon: "leaf.circle.fill", label: "Add Crop", color: .orange)
                QuickActionButton(icon: "dollarsign.circle.fill", label: "Finance", color: .blue)
                QuickActionButton(icon: "cloud.sun.fill", label: "Weather", color: .cyan)
            }
        }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Crops")
                .font(.headline)

            if store.crops.isEmpty {
                FarmCard {
                    HStack {
                        Image(systemName: "leaf.arrow.triangle.circlepath")
                            .foregroundColor(FarmTheme.subtle)
                        Text("No crops yet — add your first crop!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            } else {
                ForEach(store.crops.prefix(3)) { crop in
                    FarmCard {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(cropStatusColor(crop.status))
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(crop.name)
                                    .fontWeight(.semibold)
                                Text(crop.status.rawValue.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(crop.expectedHarvestDate, style: .date)
                                .font(.caption2)
                                .foregroundColor(FarmTheme.subtle)
                        }
                    }
                }
            }
        }
    }

    private func cropStatusColor(_ status: CropStatus) -> Color {
        switch status {
        case .planned: return .gray
        case .planted: return .blue
        case .growing: return .green
        case .readyToHarvest: return .orange
        case .harvested: return .brown
        }
    }
}

private struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: FarmTheme.shadow, radius: 4, y: 2)
    }
}
