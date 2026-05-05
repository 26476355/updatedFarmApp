import Foundation

struct SoilInfo {
    let name: String
    let characteristics: [String]
    let bestCrops: [String]
    let improvements: [String]
}

enum SoilKnowledgeBase {
    static func lookup(_ label: String) -> SoilInfo {
        let key = label.lowercased()

        if key.contains("clay") {
            return SoilInfo(
                name: "Clay Soil",
                characteristics: [
                    "Heavy, dense, and sticky when wet",
                    "Slow drainage — holds water for long periods",
                    "Rich in nutrients but poor aeration",
                    "Cracks when dry, compacts easily"
                ],
                bestCrops: [
                    "🌾 Rice, Wheat, Cabbage",
                    "🥦 Broccoli, Brussels Sprouts",
                    "🌻 Sunflowers, Asters",
                    "🍎 Apple and Pear trees (once established)"
                ],
                improvements: [
                    "Add organic compost to improve drainage and structure",
                    "Mix in gypsum to break up heavy clay",
                    "Avoid working soil when wet — causes compaction",
                    "Use raised beds for better root drainage",
                    "Mulch heavily to prevent surface cracking"
                ]
            )
        }

        if key.contains("sandy") || key.contains("sand") {
            return SoilInfo(
                name: "Sandy Soil",
                characteristics: [
                    "Light, gritty texture — easy to dig",
                    "Drains very quickly — dries out fast",
                    "Low nutrient retention, acidic tendency",
                    "Warms up quickly in spring"
                ],
                bestCrops: [
                    "🥕 Carrots, Radishes, Potatoes",
                    "🍉 Watermelon, Melon",
                    "🥜 Peanuts, Groundnuts",
                    "🌿 Herbs: Rosemary, Lavender, Thyme"
                ],
                improvements: [
                    "Add compost and organic matter to improve water retention",
                    "Use mulch to reduce evaporation",
                    "Apply fertilizer in small, frequent doses (nutrients leach quickly)",
                    "Consider drip irrigation for efficient watering",
                    "Plant cover crops to build organic matter over time"
                ]
            )
        }

        if key.contains("loam") {
            return SoilInfo(
                name: "Loamy Soil",
                characteristics: [
                    "Ideal balance of sand, silt, and clay",
                    "Good drainage while retaining moisture",
                    "Rich in nutrients and organic matter",
                    "Easy to work with, crumbly texture"
                ],
                bestCrops: [
                    "🍅 Tomatoes, Peppers, Beans",
                    "🌽 Maize, Wheat, Barley",
                    "🥬 Most vegetables thrive in loam",
                    "🌳 Fruit trees, Berry bushes"
                ],
                improvements: [
                    "Maintain with annual compost additions",
                    "Rotate crops to preserve nutrient balance",
                    "Mulch to maintain moisture and temperature",
                    "Avoid over-tilling which breaks down structure",
                    "Test pH annually — aim for 6.0-7.0"
                ]
            )
        }

        if key.contains("silt") {
            return SoilInfo(
                name: "Silty Soil",
                characteristics: [
                    "Smooth, flour-like texture when dry",
                    "Holds moisture well, fertile",
                    "Can become compacted and waterlogged",
                    "Prone to erosion by wind and water"
                ],
                bestCrops: [
                    "🥬 Lettuce, Spinach, Chard",
                    "🧅 Onions, Garlic",
                    "🌾 Rice (in wet conditions)",
                    "🍇 Grapes, Berries"
                ],
                improvements: [
                    "Add coarse organic matter to improve drainage",
                    "Avoid compaction — minimize foot traffic on beds",
                    "Use cover crops to prevent erosion",
                    "Raised beds help with drainage issues",
                    "Add composted bark to improve structure"
                ]
            )
        }

        if key.contains("peat") || key.contains("dark organic") {
            return SoilInfo(
                name: "Peaty Soil",
                characteristics: [
                    "Very dark, almost black colour",
                    "High organic matter content, spongy feel",
                    "Acidic pH (typically 3.5-5.5)",
                    "Retains large amounts of water"
                ],
                bestCrops: [
                    "🫐 Blueberries, Cranberries",
                    "🥔 Potatoes",
                    "🥕 Root vegetables",
                    "🌿 Acid-loving plants: Azaleas, Rhododendrons"
                ],
                improvements: [
                    "Add lime to raise pH if growing non-acid-loving crops",
                    "Mix in sand or grit to improve drainage",
                    "Excellent for seed starting and nursery beds",
                    "Avoid over-watering — already retains moisture",
                    "Add balanced fertilizer — peat is low in nutrients despite organic content"
                ]
            )
        }

        if key.contains("chalk") || key.contains("limestone") || key.contains("alkaline") {
            return SoilInfo(
                name: "Chalky / Alkaline Soil",
                characteristics: [
                    "Light coloured, stony, free-draining",
                    "Alkaline pH (7.5+), contains calcium carbonate",
                    "Can cause iron and manganese deficiency in plants",
                    "Shallow topsoil over chalk bedrock"
                ],
                bestCrops: [
                    "🥬 Cabbage, Cauliflower, Kale (brassicas love lime)",
                    "🌿 Lavender, Thyme, Sage",
                    "🍒 Cherries, Plums",
                    "🌾 Barley, Wheat"
                ],
                improvements: [
                    "Add acidic organic matter (pine needles, composted bark)",
                    "Use ericaceous compost for acid-loving plants",
                    "Apply chelated iron fertilizer to prevent chlorosis",
                    "Mulch heavily to build topsoil depth",
                    "Avoid adding lime — soil is already alkaline"
                ]
            )
        }

        if key.contains("red") || key.contains("laterite") {
            return SoilInfo(
                name: "Red / Laterite Soil",
                characteristics: [
                    "Reddish colour from high iron oxide content",
                    "Common in tropical and subtropical regions",
                    "Well-drained but low in nutrients",
                    "Acidic, low in nitrogen and phosphorus"
                ],
                bestCrops: [
                    "☕ Coffee, Tea, Cashew",
                    "🥜 Groundnuts, Millets",
                    "🥭 Mango, Citrus trees",
                    "🍠 Sweet Potato, Cassava"
                ],
                improvements: [
                    "Add organic compost and manure generously",
                    "Apply phosphorus-rich fertilizer (bone meal, rock phosphate)",
                    "Lime to correct acidity if pH is below 5.5",
                    "Use green manure cover crops between seasons",
                    "Mulch to prevent nutrient leaching from heavy rains"
                ]
            )
        }

        return SoilInfo(
            name: label,
            characteristics: ["Soil type could not be determined precisely"],
            bestCrops: ["Take a clearer photo in natural daylight for better results"],
            improvements: [
                "Get a professional soil test for accurate analysis",
                "Test pH, nitrogen, phosphorus, and potassium levels",
                "Send sample to local agricultural extension office"
            ]
        )
    }
}
