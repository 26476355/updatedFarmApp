import SwiftUI

struct CropPlan: Identifiable {
    let id = UUID()
    let crop: String
    let emoji: String
    let reason: String
    let plantMonth: String
    let harvestMonth: String
    let estimatedYield: String
    let estimatedRevenue: String
    let difficulty: String
    let waterNeeds: String
}

enum FarmAdvisor {
    static func generatePlan(soilType: String, fieldSize: Double, month: Int) -> [CropPlan] {
        let soil = soilType.lowercased()
        var plans: [CropPlan] = []

        let season: String
        if (9...11).contains(month) { season = "spring" }
        else if (12...12).contains(month) || (1...2).contains(month) { season = "summer" }
        else if (3...5).contains(month) { season = "autumn" }
        else { season = "winter" }

        // Soil-specific recommendations
        if soil.contains("clay") {
            plans += [
                CropPlan(crop: "Cabbage", emoji: "🥬", reason: "Clay retains moisture — cabbage thrives here", plantMonth: season == "spring" ? "Sep" : "Mar", harvestMonth: season == "spring" ? "Dec" : "Jun", estimatedYield: "\(Int(fieldSize * 8000)) kg", estimatedRevenue: "R\(Int(fieldSize * 24000))", difficulty: "Easy", waterNeeds: "Medium"),
                CropPlan(crop: "Wheat", emoji: "🌾", reason: "Deep clay roots support wheat's heavy heads", plantMonth: "May", harvestMonth: "Nov", estimatedYield: "\(Int(fieldSize * 3500)) kg", estimatedRevenue: "R\(Int(fieldSize * 14000))", difficulty: "Medium", waterNeeds: "Low"),
                CropPlan(crop: "Rice", emoji: "🍚", reason: "Clay's water retention is perfect for paddy rice", plantMonth: "Oct", harvestMonth: "Mar", estimatedYield: "\(Int(fieldSize * 5000)) kg", estimatedRevenue: "R\(Int(fieldSize * 20000))", difficulty: "Hard", waterNeeds: "Very High"),
            ]
        } else if soil.contains("sandy") || soil.contains("sand") {
            plans += [
                CropPlan(crop: "Carrots", emoji: "🥕", reason: "Sandy soil = straight, beautiful carrots with no forking", plantMonth: season == "spring" ? "Sep" : "Mar", harvestMonth: season == "spring" ? "Dec" : "Jun", estimatedYield: "\(Int(fieldSize * 6000)) kg", estimatedRevenue: "R\(Int(fieldSize * 18000))", difficulty: "Easy", waterNeeds: "Medium"),
                CropPlan(crop: "Watermelon", emoji: "🍉", reason: "Sandy soil warms fast — melons love the heat", plantMonth: "Oct", harvestMonth: "Jan", estimatedYield: "\(Int(fieldSize * 12000)) kg", estimatedRevenue: "R\(Int(fieldSize * 36000))", difficulty: "Medium", waterNeeds: "High"),
                CropPlan(crop: "Groundnuts", emoji: "🥜", reason: "Easy harvest in loose sandy soil + nitrogen fixing", plantMonth: "Nov", harvestMonth: "Apr", estimatedYield: "\(Int(fieldSize * 2000)) kg", estimatedRevenue: "R\(Int(fieldSize * 16000))", difficulty: "Easy", waterNeeds: "Low"),
            ]
        } else if soil.contains("loam") {
            plans += [
                CropPlan(crop: "Tomatoes", emoji: "🍅", reason: "Loam is the gold standard — tomatoes will explode here", plantMonth: "Sep", harvestMonth: "Jan", estimatedYield: "\(Int(fieldSize * 15000)) kg", estimatedRevenue: "R\(Int(fieldSize * 45000))", difficulty: "Medium", waterNeeds: "Medium"),
                CropPlan(crop: "Maize", emoji: "🌽", reason: "Loam's nutrient balance is ideal for high-yield maize", plantMonth: "Oct", harvestMonth: "Mar", estimatedYield: "\(Int(fieldSize * 6000)) kg", estimatedRevenue: "R\(Int(fieldSize * 18000))", difficulty: "Easy", waterNeeds: "Medium"),
                CropPlan(crop: "Peppers", emoji: "🌶️", reason: "Premium crop — loam gives consistent, high-quality peppers", plantMonth: "Sep", harvestMonth: "Feb", estimatedYield: "\(Int(fieldSize * 8000)) kg", estimatedRevenue: "R\(Int(fieldSize * 40000))", difficulty: "Medium", waterNeeds: "Medium"),
            ]
        } else {
            plans += [
                CropPlan(crop: "Spinach", emoji: "🥬", reason: "Hardy crop that adapts to most soil types", plantMonth: "Mar", harvestMonth: "May", estimatedYield: "\(Int(fieldSize * 4000)) kg", estimatedRevenue: "R\(Int(fieldSize * 12000))", difficulty: "Easy", waterNeeds: "Medium"),
                CropPlan(crop: "Beans", emoji: "🫘", reason: "Nitrogen-fixing — improves your soil while earning income", plantMonth: "Oct", harvestMonth: "Jan", estimatedYield: "\(Int(fieldSize * 3000)) kg", estimatedRevenue: "R\(Int(fieldSize * 15000))", difficulty: "Easy", waterNeeds: "Low"),
                CropPlan(crop: "Sweet Potato", emoji: "🍠", reason: "Resilient, high-calorie crop with strong market demand", plantMonth: "Sep", harvestMonth: "Mar", estimatedYield: "\(Int(fieldSize * 7000)) kg", estimatedRevenue: "R\(Int(fieldSize * 21000))", difficulty: "Easy", waterNeeds: "Low"),
            ]
        }

        // Season bonus
        if season == "spring" || season == "summer" {
            plans.append(CropPlan(crop: "Sunflowers", emoji: "🌻", reason: "High-margin oil crop + attracts pollinators for other crops", plantMonth: "Oct", harvestMonth: "Feb", estimatedYield: "\(Int(fieldSize * 1500)) kg", estimatedRevenue: "R\(Int(fieldSize * 12000))", difficulty: "Easy", waterNeeds: "Low"))
        }

        return plans
    }
}

struct FarmAdvisorView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var auth: AuthService
    @State private var selectedField: Field?
    @State private var plans: [CropPlan] = []
    @State private var showPlans = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    heroBanner
                    fieldSelector
                    if showPlans && !plans.isEmpty {
                        summaryCard
                        ForEach(plans) { plan in
                            planCard(plan)
                        }
                        disclaimerCard
                    } else if selectedField == nil {
                        promptCard
                    }
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Farm Advisor")
        }
    }

    private var heroBanner: some View {
        VStack(spacing: 8) {
            Text("🧠").font(.system(size: 44))
            Text("AI Farm Advisor").font(.title2).fontWeight(.black).foregroundColor(.white)
            Text("Tell me your field — I'll tell you what to plant,\nwhen to plant it, and how much you'll earn.")
                .font(.caption).foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center).lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(FarmTheme.boldGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var fieldSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select a field to analyze").font(.subheadline).fontWeight(.black).foregroundColor(.white)
            if store.fields.isEmpty {
                FarmCard {
                    VStack(spacing: 8) {
                        Text("🌿").font(.title)
                        Text("Add a field first").font(.caption).fontWeight(.bold).foregroundColor(.white)
                        Text("The advisor needs your field data to generate a plan")
                            .font(.caption2).foregroundColor(FarmTheme.textSecondary).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity).padding(.vertical, 8)
                }
            } else {
                ForEach(store.fields) { field in
                    Button {
                        selectedField = field
                        plans = FarmAdvisor.generatePlan(
                            soilType: field.soilType,
                            fieldSize: field.size,
                            month: Calendar.current.component(.month, from: Date())
                        )
                        withAnimation(.spring(response: 0.4)) { showPlans = true }
                    } label: {
                        HStack(spacing: 12) {
                            Text("🌿").font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(field.name).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                                Text("\(field.size, specifier: "%.1f") acres • \(field.soilType)")
                                    .font(.caption).foregroundColor(FarmTheme.accent)
                            }
                            Spacer()
                            if selectedField?.id == field.id {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(FarmTheme.accent)
                            } else {
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(FarmTheme.subtle)
                            }
                        }
                        .padding(14)
                        .background(selectedField?.id == field.id ? FarmTheme.accent.opacity(0.1) : FarmTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedField?.id == field.id ? FarmTheme.accent.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var summaryCard: some View {
        if let field = selectedField {
            let totalRevenue = plans.compactMap { Int($0.estimatedRevenue.replacingOccurrences(of: "R", with: "")) }.reduce(0, +)
            VStack(spacing: 10) {
                Text("📊 Plan for \(field.name)").font(.headline).fontWeight(.black).foregroundColor(.white)
                Text("\(field.soilType) • \(field.size, specifier: "%.1f") acres")
                    .font(.caption).foregroundColor(FarmTheme.accent)
                Divider().background(FarmTheme.subtle)
                HStack(spacing: 20) {
                    VStack(spacing: 2) {
                        Text("\(plans.count)").font(.title2).fontWeight(.black).foregroundColor(FarmTheme.accent)
                        Text("Crops").font(.caption2).foregroundColor(FarmTheme.textSecondary)
                    }
                    VStack(spacing: 2) {
                        Text("R\(totalRevenue)").font(.title2).fontWeight(.black).foregroundColor(FarmTheme.gold)
                        Text("Potential Revenue").font(.caption2).foregroundColor(FarmTheme.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(FarmTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func planCard(_ plan: CropPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(plan.emoji).font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.crop).font(.headline).fontWeight(.black).foregroundColor(.white)
                    Text(plan.reason).font(.caption).foregroundColor(FarmTheme.textSecondary).lineLimit(2)
                }
                Spacer()
            }

            Divider().background(FarmTheme.subtle)

            HStack(spacing: 16) {
                infoChip(icon: "calendar", label: "Plant", value: plan.plantMonth)
                infoChip(icon: "shippingbox", label: "Harvest", value: plan.harvestMonth)
                infoChip(icon: "scalemass", label: "Yield", value: plan.estimatedYield)
            }

            HStack(spacing: 16) {
                infoChip(icon: "banknote", label: "Revenue", value: plan.estimatedRevenue, color: FarmTheme.gold)
                infoChip(icon: "gauge.medium", label: "Difficulty", value: plan.difficulty)
                infoChip(icon: "drop", label: "Water", value: plan.waterNeeds)
            }
        }
        .padding(16)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoChip(icon: String, label: String, value: String, color: Color = FarmTheme.accent) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.caption2).foregroundColor(color)
            Text(value).font(.system(size: 11, weight: .black, design: .rounded)).foregroundColor(.white)
            Text(label).font(.system(size: 9)).foregroundColor(FarmTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var promptCard: some View {
        FarmCard {
            VStack(spacing: 10) {
                Text("👆").font(.largeTitle)
                Text("Pick a field above").font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                Text("I'll analyze your soil type, field size, and the current season to recommend the most profitable crops for you.")
                    .font(.caption).foregroundColor(FarmTheme.textSecondary)
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10)
        }
    }

    private var disclaimerCard: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle").font(.caption).foregroundColor(FarmTheme.subtle)
            Text("Estimates based on average South African yields and market prices. Actual results vary by weather, inputs, and management.")
                .font(.caption2).foregroundColor(FarmTheme.subtle)
        }
        .padding(12)
    }
}
