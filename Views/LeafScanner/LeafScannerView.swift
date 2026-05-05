import SwiftUI
import PhotosUI

enum ScanMode: String, CaseIterable {
    case leaf = "Leaf"
    case animal = "Animal"
    case soil = "Soil"

    var icon: String {
        switch self {
        case .leaf: return "leaf.fill"
        case .animal: return "hare.fill"
        case .soil: return "mountain.2.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .leaf: return "Capture a leaf image"
        case .animal: return "Capture an image of the animal"
        case .soil: return "Capture a photo of the soil"
        }
    }

    var analyzeLabel: String {
        switch self {
        case .leaf: return "Leaf"
        case .animal: return "Animal"
        case .soil: return "Soil"
        }
    }
}

struct LeafScannerView: View {
    @State private var scanMode: ScanMode = .leaf
    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var findings: [LeafFinding] = []
    @State private var isAnalyzing = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                modePicker
                imageSection
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: FarmTheme.shadow, radius: 6, y: 3)

                    if isAnalyzing {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Analyzing \(scanMode.analyzeLabel.lowercased())...")
                                .font(.subheadline).foregroundColor(.secondary)
                        }.padding()
                    } else {
                        Button { analyze(image) } label: {
                            Label("Analyze \(scanMode.analyzeLabel)",
                                  systemImage: "magnifyingglass")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(FarmTheme.gradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }

                if let error = errorMessage {
                    FarmCard {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }
                }

                ForEach(Array(findings.enumerated()), id: \.offset) { _, finding in
                    findingCard(finding)
                }
            }
            .padding()
        }
        .background(FarmTheme.background)
        .navigationTitle("Farm Scanner")
        .sheet(isPresented: $showCamera) { CameraView(image: $selectedImage) }
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    selectedImage = img
                    findings = []
                    errorMessage = nil
                }
            }
        }
        .onChange(of: scanMode) { _ in
            findings = []
            errorMessage = nil
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { scanMode = mode }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.caption)
                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(scanMode == mode ? .white : FarmTheme.primary)
                    .background(scanMode == mode ? FarmTheme.primary : FarmTheme.primary.opacity(0.08))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var imageSection: some View {
        VStack(spacing: 12) {
            if selectedImage == nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .foregroundColor(FarmTheme.primary.opacity(0.3))
                        .frame(height: 180)
                    VStack(spacing: 8) {
                        Image(systemName: scanMode.icon)
                            .font(.system(size: 40))
                            .foregroundColor(FarmTheme.primary)
                        Text(scanMode.placeholder)
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                }
            }

            HStack(spacing: 12) {
                Button { showCamera = true } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(FarmTheme.primary)
                        .background(FarmTheme.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Gallery", systemImage: "photo.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.orange)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    @ViewBuilder
    private func findingCard(_ finding: LeafFinding) -> some View {
        if scanMode == .soil, let soil = finding.soilInfo {
            soilCard(soil, confidence: finding.confidence)
        } else {
            diseaseCard(finding)
        }
    }

    private func diseaseCard(_ finding: LeafFinding) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: finding.info.symptoms.isEmpty ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(finding.info.symptoms.isEmpty ? .green : .red)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(finding.info.name).font(.headline).fontWeight(.bold)
                    Text("Confidence: \(finding.confidence, specifier: "%.0f")%")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }
            if !finding.info.symptoms.isEmpty {
                Divider()
                Text("Symptoms").font(.subheadline).fontWeight(.semibold)
                ForEach(finding.info.symptoms, id: \.self) { s in
                    bulletPoint(s, icon: "circle.fill", color: .red)
                }
                Divider()
                Text("Remediations").font(.subheadline).fontWeight(.semibold).foregroundColor(FarmTheme.primary)
                ForEach(finding.info.remediations, id: \.self) { r in
                    bulletPoint(r, icon: "checkmark.circle.fill", color: FarmTheme.primary)
                }
            }
        }
        .padding(16).background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: FarmTheme.shadow, radius: 6, y: 3)
    }

    private func soilCard(_ soil: SoilInfo, confidence: Double) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "mountain.2.fill").foregroundColor(.brown).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(soil.name).font(.headline).fontWeight(.bold)
                    Text("Confidence: \(confidence, specifier: "%.0f")%")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }

            Divider()
            Text("Characteristics").font(.subheadline).fontWeight(.semibold)
            ForEach(soil.characteristics, id: \.self) { c in
                bulletPoint(c, icon: "info.circle.fill", color: .blue)
            }

            Divider()
            Text("Best Crops").font(.subheadline).fontWeight(.semibold).foregroundColor(FarmTheme.primary)
            ForEach(soil.bestCrops, id: \.self) { crop in
                bulletPoint(crop, icon: "leaf.fill", color: FarmTheme.primary)
            }

            Divider()
            Text("Soil Improvements").font(.subheadline).fontWeight(.semibold).foregroundColor(.orange)
            ForEach(soil.improvements, id: \.self) { imp in
                bulletPoint(imp, icon: "wrench.and.screwdriver.fill", color: .orange)
            }
        }
        .padding(16).background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: FarmTheme.shadow, radius: 6, y: 3)
    }

    private func bulletPoint(_ text: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).font(.caption).foregroundColor(color).padding(.top, 2)
            Text(text).font(.caption)
        }
    }

    private func analyze(_ image: UIImage) {
        isAnalyzing = true
        errorMessage = nil
        findings = []

        let handler: (Result<[ClassificationResult], Error>) -> Void = { result in
            isAnalyzing = false
            switch result {
            case .success(let classifications):
                findings = classifications.map { c in
                    switch scanMode {
                    case .leaf:
                        return LeafFinding(info: DiseaseKnowledgeBase.lookup(c.label), soilInfo: nil, confidence: c.confidence)
                    case .animal:
                        return LeafFinding(info: AnimalKnowledgeBase.lookup(c.label), soilInfo: nil, confidence: c.confidence)
                    case .soil:
                        let soil = SoilKnowledgeBase.lookup(c.label)
                        return LeafFinding(info: DiseaseInfo(name: soil.name, symptoms: [], remediations: []), soilInfo: soil, confidence: c.confidence)
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }

        switch scanMode {
        case .leaf: LeafClassifier.shared.classify(image: image, completion: handler)
        case .animal: AnimalClassifier.shared.classify(image: image, completion: handler)
        case .soil: SoilClassifier.shared.classify(image: image, completion: handler)
        }
    }
}

struct LeafFinding {
    let info: DiseaseInfo
    var soilInfo: SoilInfo?
    let confidence: Double
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}
