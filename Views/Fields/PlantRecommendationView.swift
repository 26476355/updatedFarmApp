import SwiftUI

struct PlantRecommendationView: View {
    let soilType: String

    private var soilInfo: SoilInfo {
        SoilKnowledgeBase.lookup(soilType)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                section(title: "Recommended Crops", icon: "leaf.fill", color: FarmTheme.primary, items: soilInfo.bestCrops)
                section(title: "Soil Characteristics", icon: "mountain.2.fill", color: .brown, items: soilInfo.characteristics)
                section(title: "Improvement Tips", icon: "lightbulb.fill", color: .orange, items: soilInfo.improvements)
            }
            .padding()
        }
        .background(FarmTheme.background)
        .navigationTitle("Plant Advice")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(.white)
            Text(soilInfo.name)
                .font(.title3).fontWeight(.bold).foregroundColor(.white)
            Text("Best plants to grow in this soil")
                .font(.caption).foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(FarmTheme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func section(title: String, icon: String, color: Color, items: [String]) -> some View {
        FarmCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: icon).foregroundColor(color)
                    Text(title).font(.subheadline).fontWeight(.bold)
                }
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Circle().fill(color.opacity(0.4)).frame(width: 6, height: 6).padding(.top, 5)
                        Text(item).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PlantRecommendationBanner: View {
    let soilType: String

    private var soilInfo: SoilInfo {
        SoilKnowledgeBase.lookup(soilType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles").foregroundColor(.orange).font(.caption)
                Text("Recommended Crops").font(.caption).fontWeight(.bold)
            }
            ForEach(soilInfo.bestCrops, id: \.self) { crop in
                Text(crop).font(.caption2).foregroundColor(.secondary)
            }
        }
    }
}
