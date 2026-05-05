import Foundation

struct FarmAlert: Identifiable, Codable {
    var id = UUID()
    var type: AlertType
    var title: String
    var message: String
    var severity: AlertSeverity
    var date: Date = Date()
    var isRead: Bool = false
    var actionLabel: String?
}

enum AlertType: String, Codable {
    case frost, drought, pest, harvest, price, tip

    var icon: String {
        switch self {
        case .frost: return "snowflake"
        case .drought: return "sun.max.trianglebadge.exclamationmark"
        case .pest: return "ladybug.fill"
        case .harvest: return "calendar.badge.clock"
        case .price: return "chart.line.uptrend.xyaxis"
        case .tip: return "lightbulb.fill"
        }
    }
}

enum AlertSeverity: String, Codable {
    case info, warning, critical

    var color: String {
        switch self {
        case .info: return "blue"
        case .warning: return "orange"
        case .critical: return "red"
        }
    }
}

class AlertsService: ObservableObject {
    @Published var alerts: [FarmAlert] = []
    private let key = "farm_alerts"

    init() { load() }

    var unreadCount: Int { alerts.filter { !$0.isRead }.count }

    func generateAlerts(weather: WeatherResponse?, crops: [Crop], fields: [Field]) {
        var newAlerts: [FarmAlert] = []

        if let w = weather {
            if w.main.temp <= 2 {
                newAlerts.append(FarmAlert(
                    type: .frost, title: "⚠️ Frost Warning",
                    message: "Temperature is \(Int(w.main.temp))°C in \(w.name). Cover sensitive crops tonight. Tomatoes, peppers, and beans are at risk.",
                    severity: .critical, actionLabel: "View Fields"))
            }
            if w.main.temp > 35 {
                newAlerts.append(FarmAlert(
                    type: .drought, title: "🌡️ Extreme Heat Alert",
                    message: "Temperature is \(Int(w.main.temp))°C. Increase irrigation frequency. Mulch exposed soil to retain moisture.",
                    severity: .critical, actionLabel: "View Crops"))
            }
            if w.main.humidity > 85 {
                newAlerts.append(FarmAlert(
                    type: .pest, title: "🐛 High Humidity — Pest Risk",
                    message: "Humidity at \(w.main.humidity)% in \(w.name). High risk of fungal diseases and aphid outbreaks. Inspect crops and apply preventive spray.",
                    severity: .warning, actionLabel: "Scan Leaves"))
            }
            if w.main.humidity < 20 {
                newAlerts.append(FarmAlert(
                    type: .drought, title: "💧 Low Humidity Warning",
                    message: "Humidity at \(w.main.humidity)%. Plants may wilt faster. Consider drip irrigation and windbreaks.",
                    severity: .warning))
            }
        }

        let calendar = Calendar.current
        for crop in crops where crop.status == .growing || crop.status == .planted {
            let daysUntilHarvest = calendar.dateComponents([.day], from: Date(), to: crop.expectedHarvestDate).day ?? 0
            if daysUntilHarvest <= 7 && daysUntilHarvest >= 0 {
                newAlerts.append(FarmAlert(
                    type: .harvest, title: "🌾 Harvest Ready Soon",
                    message: "\(crop.name) is expected to be ready in \(daysUntilHarvest) day\(daysUntilHarvest == 1 ? "" : "s"). Prepare storage and transport.",
                    severity: .info, actionLabel: "View Crops"))
            }
            if daysUntilHarvest < 0 {
                newAlerts.append(FarmAlert(
                    type: .harvest, title: "⏰ Overdue Harvest",
                    message: "\(crop.name) was expected to be harvested \(abs(daysUntilHarvest)) days ago. Delayed harvest reduces quality and market value.",
                    severity: .warning, actionLabel: "Record Harvest"))
            }
        }

        let month = calendar.component(.month, from: Date())
        if (9...11).contains(month) {
            newAlerts.append(FarmAlert(
                type: .pest, title: "🦗 Pest Season Alert",
                message: "Spring pest season is active. Aphids, cutworms, and bollworms are common. Scout fields weekly and apply IPM strategies.",
                severity: .warning, actionLabel: "Scan Leaves"))
        }

        if fields.count >= 2 {
            let soilTypes = Set(fields.map { $0.soilType })
            if soilTypes.count > 1 {
                newAlerts.append(FarmAlert(
                    type: .tip, title: "💡 Diversification Tip",
                    message: "You have \(soilTypes.count) different soil types across \(fields.count) fields. Diversify crops per soil type to maximize yield and reduce risk.",
                    severity: .info, actionLabel: "View Fields"))
            }
        }

        let existingTitles = Set(alerts.map { $0.title })
        let unique = newAlerts.filter { !existingTitles.contains($0.title) }
        if !unique.isEmpty {
            alerts.insert(contentsOf: unique, at: 0)
            save()
        }
    }

    func markRead(_ alert: FarmAlert) {
        if let i = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[i].isRead = true
            save()
        }
    }

    func clearAll() { alerts = []; save() }

    private func save() {
        if let d = try? JSONEncoder().encode(alerts) { UserDefaults.standard.set(d, forKey: key) }
    }
    private func load() {
        guard let d = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([FarmAlert].self, from: d) else { return }
        alerts = decoded
    }
}
