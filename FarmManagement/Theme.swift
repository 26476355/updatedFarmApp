import SwiftUI

enum FarmTheme {
    static let primary = Color(red: 0.18, green: 0.56, blue: 0.34)
    static let primaryDark = Color(red: 0.12, green: 0.40, blue: 0.24)
    static let accent = Color(red: 0.96, green: 0.65, blue: 0.14)
    static let background = Color(red: 0.95, green: 0.96, blue: 0.94)
    static let card = Color.white
    static let subtle = Color.secondary.opacity(0.6)
    static let shadow = Color.black.opacity(0.06)

    static let gradient = LinearGradient(
        colors: [primary, primaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct FarmCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(14)
            .background(FarmTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: FarmTheme.shadow, radius: 5, y: 2)
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = FarmTheme.primary

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(FarmTheme.subtle)
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(FarmTheme.subtle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
