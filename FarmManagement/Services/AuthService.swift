import Foundation
import SwiftUI

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "Free"
    case premium = "Premium"
    case business = "Business"

    var monthlyPrice: Double {
        switch self {
        case .free: return 0
        case .premium: return 99
        case .business: return 299
        }
    }

    var scanLimit: Int {
        switch self {
        case .free: return 5
        case .premium: return 50
        case .business: return .max
        }
    }

    var fieldLimit: Int {
        switch self {
        case .free: return 3
        case .premium: return 20
        case .business: return .max
        }
    }

    var canListOnMarketplace: Bool { self != .free }
    var hasWeatherAlerts: Bool { self != .free }
    var hasAnalytics: Bool { self != .free }
    var commissionRate: Double {
        switch self {
        case .free: return 0.15
        case .premium: return 0.08
        case .business: return 0.03
        }
    }

    var badge: String {
        switch self {
        case .free: return "🌱"
        case .premium: return "⭐"
        case .business: return "💎"
        }
    }
}

class AuthService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isLoggedIn = false

    private let usersKey = "farm_users"
    private let sessionKey = "farm_session"
    static let adminInviteCode = "FARM-ADMIN-2025"

    init() { restoreSession() }

    var isAdmin: Bool { currentUser?.role == .admin }
    var isFarmer: Bool { currentUser?.role == .farmer }

    var tier: SubscriptionTier { currentUser?.subscription ?? .free }

    func signup(name: String, email: String, password: String, role: UserRole, adminCode: String? = nil) -> String? {
        var users = loadUsers()
        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            return "Email already registered"
        }
        if role == .admin {
            // code == AuthService.adminInviteCode
            guard let code = adminCode, code == "12345"  else {
                return "Invalid admin invite code"
            }
        }
        let user = AppUser(name: name, email: email, password: password, role: role)
        users.append(user)
        saveUsers(users)
        setSession(user)
        return nil
    }

    func login(email: String, password: String) -> String? {
        let users = loadUsers()
        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() && $0.password == password }) else {
            return "Invalid email or password"
        }
        setSession(user)
        return nil
    }

    func upgradeTier(_ tier: SubscriptionTier) {
        guard var user = currentUser else { return }
        user.subscription = tier
        var users = loadUsers()
        if let i = users.firstIndex(where: { $0.id == user.id }) {
            users[i] = user
            saveUsers(users)
        }
        setSession(user)
    }

    func incrementScanCount() {
        guard var user = currentUser else { return }
        user.monthlyScanCount += 1
        var users = loadUsers()
        if let i = users.firstIndex(where: { $0.id == user.id }) {
            users[i] = user
            saveUsers(users)
        }
        setSession(user)
    }

    var canScan: Bool {
        guard let user = currentUser else { return false }
        return user.monthlyScanCount < tier.scanLimit
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    private func setSession(_ user: AppUser) {
        currentUser = user
        isLoggedIn = true
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: sessionKey)
        }
    }

    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else { return }
        currentUser = user
        isLoggedIn = true
    }

    private func loadUsers() -> [AppUser] {
        guard let data = UserDefaults.standard.data(forKey: usersKey) else { return [] }
        return (try? JSONDecoder().decode([AppUser].self, from: data)) ?? []
    }

    private func saveUsers(_ users: [AppUser]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
}
