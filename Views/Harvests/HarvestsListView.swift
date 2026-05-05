import SwiftUI

struct HarvestsListView: View {
    @EnvironmentObject var store: DataStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if store.harvests.isEmpty {
                    EmptyStateView(icon: "shippingbox",
                                   title: "No Harvests Yet",
                                   subtitle: "Record your first harvest")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.harvests) { harvest in
                                FarmCard {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.12))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "shippingbox.fill")
                                                .foregroundColor(.purple)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            if let crop = store.crops.first(where: { $0.id == harvest.cropId }) {
                                                Text(crop.name).fontWeight(.semibold)
                                            }
                                            HStack(spacing: 6) {
                                                Text("\(harvest.quantity, specifier: "%.1f") \(harvest.unit)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(harvest.quality.rawValue.capitalized)
                                                    .font(.caption2)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(qualityColor(harvest.quality))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(qualityColor(harvest.quality).opacity(0.12))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                        Spacer()
                                        Text(harvest.date, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(FarmTheme.subtle)
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteHarvest(harvest)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(FarmTheme.background)
            .navigationTitle("Harvests")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(FarmTheme.primary)
                }
            }
            .sheet(isPresented: $showAdd) { AddHarvestView() }
        }
    }

    func qualityColor(_ quality: HarvestQuality) -> Color {
        switch quality {
        case .poor: return .red
        case .fair: return .orange
        case .good: return .green
        case .excellent: return .blue
        }
    }
}

struct AddHarvestView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedCropId: UUID?
    @State private var date = Date()
    @State private var quantity = ""
    @State private var unit = "kg"
    @State private var quality: HarvestQuality = .good

    var body: some View {
        NavigationStack {
            Form {
                Section("Harvest Info") {
                    Picker("Crop", selection: $selectedCropId) {
                        Text("Select").tag(UUID?.none)
                        ForEach(store.crops) { crop in
                            Text(crop.name).tag(UUID?.some(crop.id))
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Yield") {
                    TextField("Quantity", text: $quantity).keyboardType(.decimalPad)
                    TextField("Unit", text: $unit)
                    Picker("Quality", selection: $quality) {
                        ForEach(HarvestQuality.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                }
            }
            .navigationTitle("Add Harvest")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addHarvest(Harvest(cropId: selectedCropId ?? UUID(), date: date,
                                                  quantity: Double(quantity) ?? 0, unit: unit, quality: quality))
                        dismiss()
                    }
                    .disabled(selectedCropId == nil)
                    .fontWeight(.semibold)
                    .foregroundColor(FarmTheme.primary)
                }
            }
        }
    }
}
