import SwiftUI
import _PhotosUI_SwiftUI

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
                                NavigationLink(destination: PlantRecommendationView(soilType: field.soilType)) {
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
                                                HStack(spacing: 4) {
                                                    Image(systemName: "sparkles")
                                                        .font(.caption2)
                                                    Text("Tap for plant advice")
                                                        .font(.caption2)
                                                }
                                                .foregroundColor(.orange)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption).foregroundColor(FarmTheme.subtle)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
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
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var size = ""
    @State private var soilType = ""
    @State private var location = ""
    @State private var showSoilScanner = false
    @State private var soilImage: UIImage?
    @State private var isDetecting = false
    @State private var useAutoLocation = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Field Name", text: $name)
                    TextField("Size (acres)", text: $size).keyboardType(.decimalPad)
                }
                Section("Location") {
                    Toggle("Use Current Location", isOn: $useAutoLocation)
                    if useAutoLocation {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(FarmTheme.primary)
                            if locationService.placeName == "Locating..." {
                                ProgressView().controlSize(.small)
                                Text("Detecting location...").font(.caption).foregroundColor(.secondary)
                            } else {
                                Text(locationService.placeName).font(.subheadline)
                            }
                        }
                        Button {
                            locationService.requestLocation()
                        } label: {
                            Label("Refresh Location", systemImage: "arrow.clockwise")
                                .font(.caption).foregroundColor(FarmTheme.primary)
                        }
                    } else {
                        TextField("Enter location manually", text: $location)
                    }
                }
                Section("Soil Type") {
                    HStack {
                        Image(systemName: "mountain.2.fill").foregroundColor(.brown)
                        Text(soilType.isEmpty ? "Not detected yet" : soilType)
                            .foregroundColor(soilType.isEmpty ? .secondary : .primary)
                        Spacer()
                        if isDetecting {
                            ProgressView()
                        }
                    }

                    Button {
                        showSoilScanner = true
                    } label: {
                        Label("Scan Soil with Camera", systemImage: "camera.fill")
                            .foregroundColor(FarmTheme.primary)
                    }

                    if let img = soilImage {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                if !soilType.isEmpty {
                    Section("🌱 Plant Recommendations") {
                        PlantRecommendationBanner(soilType: soilType)
                    }
                }
            }
            .navigationTitle("Add Field")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let resolvedLocation = useAutoLocation ? locationService.placeName : location
                        store.addField(Field(name: name, size: Double(size) ?? 0, soilType: soilType.isEmpty ? "Unknown" : soilType, location: resolvedLocation))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(FarmTheme.primary)
                }
            }
            .sheet(isPresented: $showSoilScanner) {
                SoilCaptureSheet(image: $soilImage)
            }
            .onChange(of: soilImage) { img in
                guard let img else { return }
                isDetecting = true
                SoilClassifier.shared.classify(image: img) { result in
                    isDetecting = false
                    if case .success(let results) = result, let top = results.first {
                        soilType = SoilKnowledgeBase.lookup(top.label).name
                    }
                }
            }
            .onAppear {
                locationService.requestPermission()
            }
        }
    }
}

struct SoilCaptureSheet: View {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    @State private var photoItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 48)).foregroundColor(.brown)
                Text("Capture Soil Photo").font(.title3).fontWeight(.bold)
                Text("Take a close-up photo of the soil in natural light")
                    .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    Button { showCamera = true } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .fontWeight(.semibold).frame(maxWidth: .infinity)
                            .padding(.vertical, 14).foregroundColor(.white)
                            .background(FarmTheme.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label("Gallery", systemImage: "photo.fill")
                            .fontWeight(.semibold).frame(maxWidth: .infinity)
                            .padding(.vertical, 14).foregroundColor(FarmTheme.primary)
                            .background(FarmTheme.primary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $image)
            }
            .onChange(of: image) { _ in dismiss() }
            .onChange(of: photoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        image = img
                    }
                }
            }
        }
    }
}
