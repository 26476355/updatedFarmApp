import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var selectedTier: SubscriptionTier = .premium
    @State private var showConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Unlock Your Farm's Potential").font(.title3).fontWeight(.bold)
                    Text("Choose a plan that grows with you")
                        .font(.caption).foregroundColor(.secondary)
                }
                .padding(.top, 10)

                if auth.tier != .free {
                    currentPlanBadge
                }

                ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                    tierCard(tier)
                }

                featureComparison
            }
            .padding()
        }
        .background(FarmTheme.background)
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Upgrade to \(selectedTier.rawValue)?", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") {
                auth.upgradeTier(selectedTier)
                dismiss()
            }
        } message: {
            Text(selectedTier == .free ? "You'll switch to the free plan." : "R\(selectedTier.monthlyPrice, specifier: "%.0f")/month will be charged. Cancel anytime.")
        }
    }

    private var currentPlanBadge: some View {
        HStack(spacing: 8) {
            Text(auth.tier.badge)
            Text("Current Plan: \(auth.tier.rawValue)")
                .font(.caption).fontWeight(.semibold)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(FarmTheme.primary.opacity(0.1))
        .clipShape(Capsule())
    }

    private func tierCard(_ tier: SubscriptionTier) -> some View {
        let isCurrent = auth.tier == tier
        let isSelected = selectedTier == tier

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tier.badge).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(tier.rawValue).font(.headline).fontWeight(.bold)
                    if tier == .free {
                        Text("Get started").font(.caption2).foregroundColor(.secondary)
                    } else if tier == .premium {
                        Text("Most popular").font(.caption2).fontWeight(.semibold).foregroundColor(.orange)
                    } else {
                        Text("For commercial farms").font(.caption2).foregroundColor(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if tier.monthlyPrice == 0 {
                        Text("Free").font(.title3).fontWeight(.bold)
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("R\(tier.monthlyPrice, specifier: "%.0f")").font(.title3).fontWeight(.bold)
                            Text("/mo").font(.caption2).foregroundColor(.secondary)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                tierFeature("Scan limit: \(tier.scanLimit == .max ? "Unlimited" : "\(tier.scanLimit)/month")", included: true)
                tierFeature("Fields: \(tier.fieldLimit == .max ? "Unlimited" : "\(tier.fieldLimit)")", included: true)
                tierFeature("Sell on marketplace", included: tier.canListOnMarketplace)
                tierFeature("Smart weather alerts", included: tier.hasWeatherAlerts)
                tierFeature("Farm analytics", included: tier.hasAnalytics)
                tierFeature("Commission: \(Int(tier.commissionRate * 100))%", included: true)
            }

            if isCurrent {
                Text("Current Plan")
                    .font(.caption).fontWeight(.bold).foregroundColor(FarmTheme.primary)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(FarmTheme.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Button {
                    selectedTier = tier
                    showConfirm = true
                } label: {
                    Text(tier.monthlyPrice == 0 ? "Downgrade" : "Upgrade")
                        .font(.caption).fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(tier == .premium ? FarmTheme.gradient : LinearGradient(colors: [FarmTheme.primary], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tier == .premium ? FarmTheme.primary : Color.clear, lineWidth: 2)
        )
        .shadow(color: FarmTheme.shadow, radius: 5, y: 2)
    }

    private func tierFeature(_ text: String, included: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: included ? "checkmark.circle.fill" : "xmark.circle")
                .font(.caption2)
                .foregroundColor(included ? FarmTheme.primary : .secondary.opacity(0.4))
            Text(text).font(.caption2).foregroundColor(included ? .primary : .secondary.opacity(0.5))
        }
    }

    private var featureComparison: some View {
        VStack(spacing: 8) {
            Text("Why upgrade?").font(.caption).fontWeight(.bold)
            VStack(alignment: .leading, spacing: 6) {
                benefitRow(icon: "exclamationmark.triangle.fill", color: .red,
                           text: "A single frost can destroy R50,000+ in crops. Smart alerts pay for themselves.")
                benefitRow(icon: "chart.line.uptrend.xyaxis", color: .blue,
                           text: "Farmers using analytics grow 23% more yield on average.")
                benefitRow(icon: "storefront.fill", color: .green,
                           text: "Direct-to-consumer sales earn 40-60% more than wholesale.")
            }
        }
        .padding(16)
        .background(FarmTheme.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func benefitRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).font(.caption).foregroundColor(color).padding(.top, 2)
            Text(text).font(.caption2).foregroundColor(.secondary)
        }
    }
}
