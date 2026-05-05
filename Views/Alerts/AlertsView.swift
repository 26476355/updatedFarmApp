import SwiftUI

struct AlertsView: View {
    @EnvironmentObject var alertsService: AlertsService
    @EnvironmentObject var auth: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if !auth.tier.hasWeatherAlerts {
                        upgradePrompt
                    } else if alertsService.alerts.isEmpty {
                        EmptyStateView(icon: "bell", title: "All Clear", subtitle: "Smart alerts will appear when risks are detected")
                            .frame(minHeight: 400)
                    } else {
                        ForEach(alertsService.alerts) { alert in
                            alertRow(alert)
                                .onTapGesture { alertsService.markRead(alert) }
                        }
                    }
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Smart Alerts")
            .toolbar {
                if !alertsService.alerts.isEmpty {
                    Button("Clear All") { alertsService.clearAll() }
                        .font(.caption).fontWeight(.bold).foregroundColor(.red)
                }
            }
        }
    }

    private func alertRow(_ alert: FarmAlert) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(severityColor(alert.severity).opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: alert.type.icon)
                    .font(.system(size: 16, weight: .bold)).foregroundColor(severityColor(alert.severity))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title).font(.subheadline).fontWeight(.black)
                        .foregroundColor(alert.isRead ? .secondary : .primary)
                    Spacer()
                    if !alert.isRead {
                        Circle().fill(.red).frame(width: 8, height: 8)
                    }
                }
                Text(alert.message).font(.caption).foregroundColor(.secondary).lineLimit(3)
                Text(alert.date, style: .relative).font(.caption2).foregroundColor(FarmTheme.subtle)
            }
        }
        .padding(14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: FarmTheme.shadow, radius: 6, y: 2)
    }

    private var upgradePrompt: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().fill(Color.orange.opacity(0.08)).frame(width: 120, height: 120)
                Image(systemName: "bell.badge.fill").font(.system(size: 48)).foregroundColor(.orange)
            }
            Text("Don't fly blind").font(.title3).fontWeight(.black)
            Text("One frost warning could save your entire season.\nSmart Alerts monitors weather, pests, and harvest timing — so you don't have to.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                .padding(.horizontal, 24).lineSpacing(4)
            NavigationLink(destination: SubscriptionView()) {
                Text("Unlock Smart Alerts →")
                    .fontWeight(.black).foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 14)
                    .background(FarmTheme.warmGradient)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

    private func severityColor(_ severity: AlertSeverity) -> Color {
        switch severity {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }
}
