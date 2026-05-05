import SwiftUI

struct AdminFarmDataView: View {
    @EnvironmentObject var store: DataStore
    @State private var tab = 0
    @State private var editingField: Field?
    @State private var editingCrop: Crop?
    @State private var editingLivestock: Livestock?
    @State private var deleteTarget: DeleteTarget?

    enum DeleteTarget: Identifiable {
        case field(Field), crop(Crop), livestock(Livestock), harvest(Harvest)
        var id: String {
            switch self {
            case .field(let f): return f.id.uuidString
            case .crop(let c): return c.id.uuidString
            case .livestock(let l): return l.id.uuidString
            case .harvest(let h): return h.id.uuidString
            }
        }
        var name: String {
            switch self {
            case .field(let f): return f.name
            case .crop(let c): return c.name
            case .livestock(let l): return l.name
            case .harvest: return "this harvest"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                picker
                ScrollView {
                    VStack(spacing: 12) {
                        switch tab {
                        case 0: fieldsSection
                        case 1: cropsSection
                        case 2: livestockSection
                        default: harvestsSection
                        }
                    }
                    .padding()
                }
            }
            .background(FarmTheme.background)
            .navigationTitle("Farm Data")
            .sheet(item: $editingField) { field in EditFieldSheet(field: field) }
            .sheet(item: $editingCrop) { crop in EditCropSheet(crop: crop) }
            .sheet(item: $editingLivestock) { item in EditLivestockSheet(livestock: item) }
            .alert("Delete \(deleteTarget?.name ?? "")?", isPresented: Binding(
                get: { deleteTarget != nil }, set: { if !$0 { deleteTarget = nil } }
            )) {
                Button("Cancel", role: .cancel) { deleteTarget = nil }
                Button("Delete", role: .destructive) { performDelete() }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private var picker: some View {
        HStack(spacing: 0) {
            tabButton("Fields", icon: "leaf.fill", index: 0, count: store.fields.count)
            tabButton("Crops", icon: "carrot.fill", index: 1, count: store.crops.count)
            tabButton("Livestock", icon: "hare.fill", index: 2, count: store.livestock.count)
            tabButton("Harvests", icon: "shippingbox.fill", index: 3, count: store.harvests.count)
        }
        .padding(4)
        .background(FarmTheme.card)
    }

    private func tabButton(_ label: String, icon: String, index: Int, count: Int) -> some View {
        Button { withAnimation { tab = index } } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: icon).font(.caption2)
                    Text(label).font(.caption2).fontWeight(.bold)
                }
                Text("\(count)").font(.system(size: 11, weight: .black, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(tab == index ? .white : FarmTheme.textSecondary)
            .background(tab == index ? FarmTheme.primary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Fields
    @ViewBuilder
    private var fieldsSection: some View {
        if store.fields.isEmpty {
            emptyCard("No fields yet", icon: "leaf.fill")
        } else {
            ForEach(store.fields) { field in
                crudCard(
                    emoji: "🌿", title: field.name,
                    subtitle: "\(field.size) acres • \(field.soilType)",
                    detail: "📍 \(field.location)",
                    onEdit: { editingField = field },
                    onDelete: { deleteTarget = .field(field) }
                )
            }
        }
    }

    // MARK: - Crops
    @ViewBuilder
    private var cropsSection: some View {
        if store.crops.isEmpty {
            emptyCard("No crops yet", icon: "carrot.fill")
        } else {
            ForEach(store.crops) { crop in
                crudCard(
                    emoji: "🌾", title: crop.name,
                    subtitle: crop.status.rawValue.capitalized,
                    detail: "Harvest: \(crop.expectedHarvestDate.formatted(date: .abbreviated, time: .omitted))",
                    onEdit: { editingCrop = crop },
                    onDelete: { deleteTarget = .crop(crop) }
                )
            }
        }
    }

    // MARK: - Livestock
    @ViewBuilder
    private var livestockSection: some View {
        if store.livestock.isEmpty {
            emptyCard("No livestock yet", icon: "hare.fill")
        } else {
            ForEach(store.livestock) { item in
                crudCard(
                    emoji: "🐄", title: item.name,
                    subtitle: "\(item.type) • \(item.breed)",
                    detail: "Count: \(item.count)",
                    onEdit: { editingLivestock = item },
                    onDelete: { deleteTarget = .livestock(item) }
                )
            }
        }
    }

    // MARK: - Harvests
    @ViewBuilder
    private var harvestsSection: some View {
        if store.harvests.isEmpty {
            emptyCard("No harvests yet", icon: "shippingbox.fill")
        } else {
            ForEach(store.harvests) { harvest in
                let cropName = store.crops.first(where: { $0.id == harvest.cropId })?.name ?? "Unknown"
                HStack(spacing: 12) {
                    Text("📦").font(.title2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(cropName).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        Text("\(harvest.quantity, specifier: "%.1f") \(harvest.unit) • \(harvest.quality.rawValue.capitalized)")
                            .font(.caption).foregroundColor(FarmTheme.textSecondary)
                    }
                    Spacer()
                    Button(role: .destructive) { deleteTarget = .harvest(harvest) } label: {
                        Image(systemName: "trash.circle.fill").font(.title3).foregroundColor(.red.opacity(0.7))
                    }
                }
                .padding(14)
                .background(FarmTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    // MARK: - Helpers
    private func crudCard(emoji: String, title: String, subtitle: String, detail: String, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.title2)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                Text(subtitle).font(.caption).foregroundColor(FarmTheme.accent)
                Text(detail).font(.caption2).foregroundColor(FarmTheme.textSecondary)
            }
            Spacer()
            Button { onEdit() } label: {
                Image(systemName: "pencil.circle.fill").font(.title3).foregroundColor(FarmTheme.accent)
            }
            Button(role: .destructive) { onDelete() } label: {
                Image(systemName: "trash.circle.fill").font(.title3).foregroundColor(.red.opacity(0.7))
            }
        }
        .padding(14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func emptyCard(_ text: String, icon: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.title).foregroundColor(FarmTheme.accent.opacity(0.4))
            Text(text).font(.caption).foregroundColor(FarmTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(40)
        .background(FarmTheme.card).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func performDelete() {
        guard let target = deleteTarget else { return }
        switch target {
        case .field(let f): store.deleteField(f)
        case .crop(let c): store.deleteCrop(c)
        case .livestock(let l): store.deleteLivestock(l)
        case .harvest(let h): store.deleteHarvest(h)
        }
        deleteTarget = nil
    }
}

// MARK: - Edit Sheets
struct EditFieldSheet: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State var field: Field

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $field.name)
                TextField("Size (acres)", value: $field.size, format: .number)
                TextField("Soil Type", text: $field.soilType)
                TextField("Location", text: $field.location)
                TextField("Notes", text: $field.notes)
            }
            .navigationTitle("Edit Field")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { store.updateField(field); dismiss() }
                        .fontWeight(.bold).foregroundColor(FarmTheme.accent)
                }
            }
        }
    }
}

struct EditCropSheet: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State var crop: Crop

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $crop.name)
                Picker("Status", selection: $crop.status) {
                    ForEach(CropStatus.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                }
                DatePicker("Planted", selection: $crop.plantedDate, displayedComponents: .date)
                DatePicker("Expected Harvest", selection: $crop.expectedHarvestDate, displayedComponents: .date)
            }
            .navigationTitle("Edit Crop")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { store.updateCrop(crop); dismiss() }
                        .fontWeight(.bold).foregroundColor(FarmTheme.accent)
                }
            }
        }
    }
}

struct EditLivestockSheet: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State var livestock: Livestock

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $livestock.name)
                TextField("Type", text: $livestock.type)
                TextField("Breed", text: $livestock.breed)
                TextField("Count", value: $livestock.count, format: .number)
            }
            .navigationTitle("Edit Livestock")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { store.updateLivestock(livestock); dismiss() }
                        .fontWeight(.bold).foregroundColor(FarmTheme.accent)
                }
            }
        }
    }
}
