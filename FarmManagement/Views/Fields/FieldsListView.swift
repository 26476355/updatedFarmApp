import SwiftUI

struct FieldsListView: View {
    @EnvironmentObject var store: DataStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if store.fields.isEmpty {
                    EmptyStateView(icon: "leaf.arrow.triangle.circlepath",
                                   title: "No Fields Yet",
                                   subtitle: "Tap + to add your first field")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.fields) { field in
                                FarmCard {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(FarmTheme.primary.opacity(0.12))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "leaf.fill")
                                                .foregroundColor(FarmTheme.primary)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(field.name)
                                                .fontWeight(.semibold)
                                            Text("\(field.size, specifier: "%.1f") acres • \(field.soilType)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            HStack(spacing: 4) {
                                                Image(systemName: "mappin")
                                                    .font(.caption2)
                                                Text(field.location)
                                                    .font(.caption2)
                                            }
                                            .foregroundColor(FarmTheme.subtle)
                                        }
                                        Spacer()
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteField(field)
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
            .navigationTitle("Fields")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(FarmTheme.primary)
                }
            }
            .sheet(isPresented: $showAdd) { AddFieldView() }
        }
    }
}

struct AddFieldView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var size = ""
    @State private var soilType = ""
    @State private var location = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Field Name", text: $name)
                    TextField("Size (acres)", text: $size).keyboardType(.decimalPad)
                    TextField("Soil Type", text: $soilType)
                    TextField("Location", text: $location)
                }
            }
            .navigationTitle("Add Field")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addField(Field(name: name, size: Double(size) ?? 0, soilType: soilType, location: location))
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
