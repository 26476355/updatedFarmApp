import SwiftUI

enum FarmTheme {
    // Core palette: black + green
    static let primary = Color(red: 0.10, green: 0.52, blue: 0.30)
    static let primaryDark = Color(red: 0.04, green: 0.22, blue: 0.12)
    static let accent = Color(red: 0.30, green: 0.85, blue: 0.45)
    static let background = Color(red: 0.06, green: 0.06, blue: 0.07)
    static let card = Color(red: 0.11, green: 0.12, blue: 0.13)
    static let subtle = Color.white.opacity(0.35)
    static let shadow = Color.black.opacity(0.4)
    static let danger = Color(red: 0.92, green: 0.26, blue: 0.22)
    static let gold = Color(red: 1.0, green: 0.78, blue: 0.18)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.55)

    static let gradient = LinearGradient(
        colors: [Color(red: 0.08, green: 0.45, blue: 0.25), Color(red: 0.02, green: 0.15, blue: 0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.55, blue: 0.15), Color(red: 0.90, green: 0.35, blue: 0.10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let boldGradient = LinearGradient(
        colors: [Color(red: 0.12, green: 0.55, blue: 0.30), Color(red: 0.04, green: 0.18, blue: 0.10), .black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [Color(red: 0.13, green: 0.14, blue: 0.15), Color(red: 0.09, green: 0.10, blue: 0.11)],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct FarmCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(16)
            .background(FarmTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: FarmTheme.shadow, radius: 8, y: 3)
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = FarmTheme.accent

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label).font(.caption2).foregroundColor(FarmTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: FarmTheme.shadow, radius: 4, y: 2)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    private var dialogue: String {
        switch icon {
        case "tray": return "Your orders inbox is waiting.\nOnce customers start buying, you'll manage everything here."
        case "leaf.arrow.triangle.circlepath": return "Every great farm starts with a single field.\nTap + above to plant your future."
        case "carrot": return "What will you grow this season?\nAdd your first crop and let's track it together."
        case "hare": return "No animals on the farm yet?\nAdd your livestock and we'll help you manage them."
        case "shippingbox": return "Harvest season hasn't started yet.\nWhen it does, record every yield here."
        case "bell": return "All quiet on the farm front.\nWe'll alert you the moment weather or pests threaten your crops."
        case "cart": return "Your cart is feeling light!\nBrowse the marketplace for seeds, plants, and livestock."
        default: return subtitle
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle().fill(FarmTheme.accent.opacity(0.06)).frame(width: 140, height: 140)
                Circle().fill(FarmTheme.accent.opacity(0.10)).frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(FarmTheme.accent.opacity(0.7))
            }
            Text(title).font(.title3).fontWeight(.black).foregroundColor(.white)
            Text(dialogue)
                .font(.subheadline).foregroundColor(FarmTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40).lineSpacing(4)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
