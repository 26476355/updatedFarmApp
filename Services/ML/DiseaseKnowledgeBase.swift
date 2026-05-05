import Foundation

struct DiseaseInfo {
    let name: String
    let symptoms: [String]
    let remediations: [String]
}

enum DiseaseKnowledgeBase {
    static func lookup(_ label: String) -> DiseaseInfo {
        let key = label.lowercased()

        if key.contains("blight") && key.contains("early") {
            return DiseaseInfo(
                name: "Early Blight",
                symptoms: [
                    "Dark concentric ring spots (target-like) on lower leaves",
                    "Yellowing around lesions",
                    "Leaves dry out and drop prematurely"
                ],
                remediations: [
                    "Remove infected lower leaves immediately",
                    "Apply chlorothalonil or mancozeb fungicide every 7-10 days",
                    "Mulch around plants to prevent soil splash",
                    "Ensure 60-90cm spacing between plants for airflow",
                    "Rotate crops — avoid planting tomatoes/potatoes in same spot for 2 years"
                ]
            )
        }

        if key.contains("blight") {
            return DiseaseInfo(
                name: "Leaf Blight",
                symptoms: [
                    "Brown irregular spots on leaf surface",
                    "Yellowing around lesion edges",
                    "Wilting of affected leaf tips"
                ],
                remediations: [
                    "Remove and destroy infected leaves immediately",
                    "Apply copper-based fungicide (Bordeaux mixture)",
                    "Improve air circulation between plants",
                    "Switch to drip irrigation — avoid wetting foliage",
                    "Rotate crops next season to break disease cycle"
                ]
            )
        }

        if key.contains("mildew") || key.contains("powdery") {
            return DiseaseInfo(
                name: "Powdery Mildew",
                symptoms: [
                    "White powdery coating on leaf surface",
                    "Curling and distortion of young leaves",
                    "Premature leaf drop"
                ],
                remediations: [
                    "Spray neem oil solution (2-3 tbsp per gallon of water)",
                    "Apply sulfur-based fungicide in early morning",
                    "Increase plant spacing for better airflow",
                    "Remove heavily infected leaves and dispose off-site",
                    "Water at the base of plants, never on foliage"
                ]
            )
        }

        if key.contains("nitrogen") || key.contains("deficiency") {
            return DiseaseInfo(
                name: "Nitrogen Deficiency",
                symptoms: [
                    "Uniform yellowing starting from older/lower leaves",
                    "Stunted growth and small leaf size",
                    "Pale green to yellow coloration overall"
                ],
                remediations: [
                    "Apply nitrogen-rich fertilizer (urea or ammonium nitrate)",
                    "Add compost or well-rotted manure to soil",
                    "Foliar spray of diluted fish emulsion for quick uptake",
                    "Test soil pH — nitrogen uptake is best at pH 6.0-7.0",
                    "Plant nitrogen-fixing cover crops (clover, beans) nearby"
                ]
            )
        }

        if key.contains("rust") {
            return DiseaseInfo(
                name: "Leaf Rust",
                symptoms: [
                    "Orange-brown pustules on leaf undersides",
                    "Yellow spots on upper leaf surface",
                    "Premature defoliation in severe cases"
                ],
                remediations: [
                    "Apply triazole fungicide (propiconazole) at first sign",
                    "Remove and burn infected plant debris",
                    "Avoid overhead irrigation",
                    "Plant rust-resistant varieties when available",
                    "Ensure good air circulation by proper spacing"
                ]
            )
        }

        if key.contains("spot") || key.contains("septoria") {
            return DiseaseInfo(
                name: "Leaf Spot (Septoria)",
                symptoms: [
                    "Small circular spots with dark borders and grey centres",
                    "Spots appear first on lower leaves",
                    "Heavy spotting causes leaf yellowing and drop"
                ],
                remediations: [
                    "Apply copper fungicide or chlorothalonil spray",
                    "Remove infected leaves and fallen debris",
                    "Stake plants to keep foliage off the ground",
                    "Water at soil level, avoid splashing",
                    "Practice 3-year crop rotation"
                ]
            )
        }

        if key.contains("healthy") {
            return DiseaseInfo(
                name: "Healthy Leaf ✅",
                symptoms: [],
                remediations: []
            )
        }

        return DiseaseInfo(
            name: label,
            symptoms: ["Visual anomalies detected that require closer inspection"],
            remediations: [
                "Take a closer photo with better lighting for re-analysis",
                "Consult a local agricultural extension officer",
                "Isolate the affected plant to prevent potential spread",
                "Monitor neighbouring plants for similar symptoms"
            ]
        )
    }
}
