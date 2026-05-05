import CoreML
import Vision
import UIKit

struct ClassificationResult {
    let label: String
    let confidence: Double
}

class LeafClassifier {
    static let shared = LeafClassifier()

    private var vnModel: VNCoreMLModel?

    private init() {
        // Attempts to load a CoreML model named "LeafDisease" from the app bundle.
        // If no model is found, falls back to heuristic analysis.
        if let modelURL = Bundle.main.url(forResource: "LeafDisease", withExtension: "mlmodelc"),
           let compiled = try? MLModel(contentsOf: modelURL),
           let vn = try? VNCoreMLModel(for: compiled) {
            vnModel = vn
        }
    }

    var isModelAvailable: Bool { vnModel != nil }

    func classify(image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(ClassifierError.invalidImage))
            return
        }

        if let model = vnModel {
            classifyWithCoreML(cgImage: cgImage, model: model, completion: completion)
        } else {
            classifyWithHeuristics(image: image, completion: completion)
        }
    }

    // MARK: - CoreML Classification
    private func classifyWithCoreML(cgImage: CGImage, model: VNCoreMLModel, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let observations = request.results as? [VNClassificationObservation] else {
                completion(.failure(ClassifierError.noResults))
                return
            }
            let results = observations.prefix(3).map {
                ClassificationResult(label: $0.identifier, confidence: Double($0.confidence) * 100)
            }
            DispatchQueue.main.async { completion(.success(results)) }
        }
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - Heuristic Fallback (color-based analysis when no ML model is available)
    private func classifyWithHeuristics(image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let analysis = self.analyzeColors(image: image)
            DispatchQueue.main.async { completion(.success(analysis)) }
        }
    }

    private func analyzeColors(image: UIImage) -> [ClassificationResult] {
        guard let cgImage = image.cgImage else { return [] }

        let width = min(cgImage.width, 100)
        let height = min(cgImage.height, 100)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &pixelData, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return [] }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var greenPixels = 0
        var yellowPixels = 0
        var brownPixels = 0
        var whitePixels = 0
        var totalPixels = 0

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = Double(pixelData[offset]) / 255.0
                let g = Double(pixelData[offset + 1]) / 255.0
                let b = Double(pixelData[offset + 2]) / 255.0

                totalPixels += 1

                if g > 0.4 && g > r * 1.2 && g > b * 1.2 {
                    greenPixels += 1
                } else if r > 0.5 && g > 0.4 && b < 0.3 {
                    yellowPixels += 1
                } else if r > 0.3 && g < 0.3 && b < 0.2 {
                    brownPixels += 1
                } else if r > 0.85 && g > 0.85 && b > 0.85 {
                    whitePixels += 1
                }
            }
        }

        let greenRatio = Double(greenPixels) / Double(totalPixels)
        let yellowRatio = Double(yellowPixels) / Double(totalPixels)
        let brownRatio = Double(brownPixels) / Double(totalPixels)
        let whiteRatio = Double(whitePixels) / Double(totalPixels)

        var results: [ClassificationResult] = []

        if brownRatio > 0.15 {
            results.append(ClassificationResult(label: "Leaf Blight", confidence: min(brownRatio * 300, 95)))
        }
        if whiteRatio > 0.2 {
            results.append(ClassificationResult(label: "Powdery Mildew", confidence: min(whiteRatio * 250, 95)))
        }
        if yellowRatio > 0.25 && greenRatio < 0.3 {
            results.append(ClassificationResult(label: "Nitrogen Deficiency", confidence: min(yellowRatio * 200, 90)))
        }
        if yellowRatio > 0.15 && brownRatio > 0.1 {
            results.append(ClassificationResult(label: "Early Blight", confidence: min((yellowRatio + brownRatio) * 150, 88)))
        }
        if greenRatio > 0.4 && brownRatio < 0.05 && yellowRatio < 0.1 {
            results.append(ClassificationResult(label: "Healthy", confidence: min(greenRatio * 150, 96)))
        }

        if results.isEmpty {
            results.append(ClassificationResult(label: "Unknown - Manual inspection recommended", confidence: 50))
        }

        return results.sorted { $0.confidence > $1.confidence }
    }
}

enum ClassifierError: LocalizedError {
    case invalidImage, noResults

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Could not process the image"
        case .noResults: return "No classification results returned"
        }
    }
}
