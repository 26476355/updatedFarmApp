import SwiftUI

struct CropsListView: View {
    @EnvironmentObject var store: DataStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if store.crops.isEmpty {
                    EmptyStateView(icon: "carrot",
                                   title: "No Crops Yet",
                                   subtitle: "Tap + to plant your first crop")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.crops) { crop in
                                FarmCard {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(statusColor(crop.status).opacity(0.12))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "carrot.fill")
                                                .foregroundColor(statusColor(crop.status))
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(crop.name)
                                                .fontWeight(.semibold)
                                            HStack(spacing: 6) {
                                                Text(crop.status.rawValue.capitalized)
                                                    .font(.caption2)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(statusColor(crop.status))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(statusColor(crop.status).opacity(0.12))
                                                    .clipShape(Capsule())
                                                if let field = store.fields.first(where: { $0.id == crop.fieldId }) {
                                                    Text(field.name)
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("Harvest")
                                                .font(.caption2)
                                                .foregroundColor(FarmTheme.subtle)
                                            Text(crop.expectedHarvestDate, style: .date)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteCrop(crop)
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
            .navigationTitle("Crops")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(FarmTheme.primary)
                }
            }
            .sheet(isPresented: $showAdd) { AddCropView() }
        }
    }

    func statusColor(_ status: CropStatus) -> Color {
        switch status {
        case .planned: return .gray
        case .planted: return .blue
        case .growing: return .green
        case .readyToHarvest: return .orange
        case .harvested: return .brown
        }
    }
}

struct AddCropView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var selectedFieldId: UUID?
    @State private var plantedDate = Date()
    @State private var expectedHarvestDate = Date()
    @State private var status: CropStatus = .planted

    var body: some View {
        NavigationStack {
            Form {
                Section("Crop Info") {
                    TextField("Crop Name", text: $name)
                    Picker("Field", selection: $selectedFieldId) {
                        Text("None").tag(UUID?.none)
                        ForEach(store.fields) { field in
                            Text(field.name).tag(UUID?.some(field.id))
                        }
                    }
                    Picker("Status", selection: $status) {
                        ForEach(CropStatus.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                }
                Section("Dates") {
                    DatePicker("Planted", selection: $plantedDate, displayedComponents: .date)
                    DatePicker("Expected Harvest", selection: $expectedHarvestDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Crop")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addCrop(Crop(name: name, fieldId: selectedFieldId ?? UUID(),
                                           plantedDate: plantedDate, expectedHarvestDate: expectedHarvestDate, status: status))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(FarmTheme.primary)
                }
            }
        }
    }
}
