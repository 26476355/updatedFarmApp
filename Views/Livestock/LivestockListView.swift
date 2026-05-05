import SwiftUI

struct LivestockListView: View {
    @EnvironmentObject var store: DataStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if store.livestock.isEmpty {
                    EmptyStateView(icon: "hare",
                                   title: "No Livestock Yet",
                                   subtitle: "Tap + to add your animals")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.livestock) { item in
                                FarmCard {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.brown.opacity(0.12))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "hare.fill")
                                                .foregroundColor(.brown)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .fontWeight(.semibold)
                                            Text("\(item.type) • \(item.breed)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("\(item.count)")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(FarmTheme.primary)
                                            Text("head")
                                                .font(.caption2)
                                                .foregroundColor(FarmTheme.subtle)
                                        }
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteLivestock(item)
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
            .navigationTitle("Livestock")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(FarmTheme.primary)
                }
            }
            .sheet(isPresented: $showAdd) { AddLivestockView() }
        }
    }
}

struct AddLivestockView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var type = ""
    @State private var breed = ""
    @State private var count = ""
    @State private var selectedFieldId: UUID?
    @State private var dateAcquired = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Animal Info") {
                    TextField("Name", text: $name)
                    TextField("Type (e.g. Cattle, Poultry)", text: $type)
                    TextField("Breed", text: $breed)
                    TextField("Count", text: $count).keyboardType(.numberPad)
                }
                Section("Assignment") {
                    Picker("Field", selection: $selectedFieldId) {
                        Text("None").tag(UUID?.none)
                        ForEach(store.fields) { field in
                            Text(field.name).tag(UUID?.some(field.id))
                        }
                    }
                    DatePicker("Date Acquired", selection: $dateAcquired, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Livestock")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addLivestock(Livestock(name: name, type: type, breed: breed,
                                                     count: Int(count) ?? 0, fieldId: selectedFieldId, dateAcquired: dateAcquired))
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
