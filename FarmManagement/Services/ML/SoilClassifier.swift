import UIKit
import Vision
import CoreML

class SoilClassifier {
    static let shared = SoilClassifier()

    private var vnModel: VNCoreMLModel?

    private init() {
        if let url = Bundle.main.url(forResource: "SoilType", withExtension: "mlmodelc"),
           let compiled = try? MLModel(contentsOf: url),
           let vn = try? VNCoreMLModel(for: compiled) {
            vnModel = vn
        }
    }

    var isModelAvailable: Bool { vnModel != nil }

    func classify(image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(ClassifierError.invalidImage)); return
        }
        if let model = vnModel {
            runCoreML(cgImage: cgImage, model: model, completion: completion)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let results = self.analyzeColors(cgImage: cgImage)
                DispatchQueue.main.async { completion(.success(results)) }
            }
        }
    }

    private func runCoreML(cgImage: CGImage, model: VNCoreMLModel, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        let req = VNCoreMLRequest(model: model) { req, err in
            if let err = err { completion(.failure(err)); return }
            guard let obs = req.results as? [VNClassificationObservation] else {
                completion(.failure(ClassifierError.noResults)); return
            }
            let r = obs.prefix(3).map { ClassificationResult(label: $0.identifier, confidence: Double($0.confidence) * 100) }
            DispatchQueue.main.async { completion(.success(r)) }
        }
        req.imageCropAndScaleOption = .centerCrop
        DispatchQueue.global(qos: .userInitiated).async {
            do { try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([req]) }
            catch { DispatchQueue.main.async { completion(.failure(error)) } }
        }
    }

    private func analyzeColors(cgImage: CGImage) -> [ClassificationResult] {
        let w = min(cgImage.width, 120), h = min(cgImage.height, 120)
        var px = [UInt8](repeating: 0, count: w * h * 4)
        guard let ctx = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8,
                                  bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [] }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))

        var totalR = 0.0, totalG = 0.0, totalB = 0.0
        var brightness = 0.0
        let total = Double(w * h)

        for y in 0..<h {
            for x in 0..<w {
                let o = (y * w + x) * 4
                let r = Double(px[o]) / 255, g = Double(px[o+1]) / 255, b = Double(px[o+2]) / 255
                totalR += r; totalG += g; totalB += b
                brightness += (r + g + b) / 3
            }
        }

        let avgR = totalR / total, avgG = totalG / total, avgB = totalB / total
        let avgBright = brightness / total

        var results: [ClassificationResult] = []

        // Very dark soil → Peaty
        if avgBright < 0.2 {
            results.append(.init(label: "Peaty / Dark Organic Soil", confidence: min(90, (0.25 - avgBright) * 500)))
        }

        // Reddish soil → Red/Laterite
        if avgR > 0.4 && avgR > avgG * 1.4 && avgR > avgB * 1.6 {
            results.append(.init(label: "Red / Laterite Soil", confidence: min(92, avgR * 120)))
        }

        // Very light / white-ish → Chalky
        if avgBright > 0.7 && avgR > 0.65 && avgG > 0.6 && avgB > 0.55 {
            results.append(.init(label: "Chalky / Alkaline Soil", confidence: min(85, avgBright * 110)))
        }

        // Yellowish-tan → Sandy
        if avgR > 0.5 && avgG > 0.4 && avgB < 0.35 && avgBright > 0.4 {
            results.append(.init(label: "Sandy Soil", confidence: min(88, (avgR + avgG - avgB) * 80)))
        }

        // Medium brown, balanced → Clay
        if avgR > 0.3 && avgR < 0.55 && avgG > 0.2 && avgG < 0.4 && avgB > 0.1 && avgB < 0.3 && avgBright < 0.45 {
            results.append(.init(label: "Clay Soil", confidence: min(84, (1 - avgBright) * 120)))
        }

        // Greyish smooth → Silty
        let greyness = 1.0 - (abs(avgR - avgG) + abs(avgG - avgB) + abs(avgR - avgB))
        if greyness > 2.7 && avgBright > 0.35 && avgBright < 0.6 {
            results.append(.init(label: "Silty Soil", confidence: min(80, greyness * 30)))
        }

        // Medium brown, good balance → Loamy (ideal)
        if avgBright > 0.25 && avgBright < 0.55 && avgR > 0.3 && avgG > 0.2 {
            let loamScore = (1 - abs(avgR - avgG * 1.3)) * 100
            if loamScore > 50 {
                results.append(.init(label: "Loamy Soil", confidence: min(86, loamScore)))
            }
        }

        if results.isEmpty {
            results.append(.init(label: "Unknown Soil Type", confidence: 50))
        }

        return results.sorted { $0.confidence > $1.confidence }
    }
}
