import SwiftUI

@main
struct FarmManagementApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var weatherService = WeatherService()
    @StateObject private var locationService = LocationService()
    @StateObject private var auth = AuthService()
    @StateObject private var marketplace = MarketplaceStore()
    @StateObject private var alertsService = AlertsService()

    var body: some Scene {
        WindowGroup {
            Group {
                if !auth.isLoggedIn {
                    LoginView()
                } else if auth.isAdmin {
                    AdminTabView()
                } else if auth.isFarmer {
                    FarmerTabView()
                } else {
                    CustomerTabView()
                }
            }
            .environmentObject(store)
            .environmentObject(weatherService)
            .environmentObject(locationService)
            .environmentObject(auth)
            .environmentObject(marketplace)
            .environmentObject(alertsService)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Admin
struct AdminTabView: View {
    @EnvironmentObject var auth: AuthService
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Home", systemImage: "house.fill") }
            AdminListingsView().tabItem { Label("Listings", systemImage: "tag.fill") }
            AdminOrdersView().tabItem { Label("Orders", systemImage: "shippingbox.fill") }
            AdminFarmDataView().tabItem { Label("Farm Data", systemImage: "leaf.fill") }
            FinancesView().tabItem { Label("Finances", systemImage: "banknote.fill") }
        }.tint(FarmTheme.accent)
    }
}

// MARK: - Farmer
struct FarmerTabView: View {
    @EnvironmentObject var alertsService: AlertsService
    var body: some View {
        TabView {
            FarmerDashboardView().tabItem { Label("Farm", systemImage: "house.fill") }
            FarmAdvisorView().tabItem { Label("Advisor", systemImage: "brain.head.profile") }
            LeafScannerView().tabItem { Label("Scanner", systemImage: "camera.viewfinder") }
            AlertsView().tabItem { Label("Alerts", systemImage: "bell.fill") }.badge(alertsService.unreadCount)
            FarmerProfileView().tabItem { Label("Profile", systemImage: "person.fill") }
        }.tint(FarmTheme.accent)
    }
}

// MARK: - Customer
struct CustomerTabView: View {
    @EnvironmentObject var marketplace: MarketplaceStore
    var body: some View {
        TabView {
            MarketplaceView().tabItem { Label("Shop", systemImage: "storefront.fill") }
            CustomerCartView().tabItem { Label("Cart", systemImage: "cart.fill") }.badge(marketplace.cart.count)
            OrdersView().tabItem { Label("Orders", systemImage: "shippingbox.fill") }
            ProfileView().tabItem { Label("Profile", systemImage: "person.fill") }
        }.tint(FarmTheme.accent)
    }
}

// MARK: - Farmer Dashboard
struct FarmerDashboardView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var alertsService: AlertsService
    @EnvironmentObject var auth: AuthService
    @State private var showAddCrop = false

    private var firstName: String {
        auth.currentUser?.name.components(separatedBy: " ").first ?? "Farmer"
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Rise and shine, \(firstName)! 🌅" }
        if hour < 17 { return "Keep pushing, \(firstName)! ☀️" }
        return "Winding down, \(firstName)? 🌙"
    }

    private var dailyTip: String {
        let tips = [
            "\"The best fertilizer is the farmer's footprint.\"",
            "Data-driven farming isn't the future — it's the now.",
            "Every seed you plant today is a harvest you'll celebrate tomorrow.",
            "Your soil is your savings account. Invest in it wisely.",
            "A single frost warning can save your entire season.",
            "Farmers who track yields grow 23% more on average.",
            "Direct-to-consumer sales earn 40-60% more than wholesale."
        ]
        return tips[Calendar.current.component(.day, from: Date()) % tips.count]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    heroBanner
                    criticalAlert
                    upgradeBanner
                    statsRow
                    quickActions
                    harvestCountdown
                    cropsList
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("My Farm")
            .onAppear {
                locationService.requestPermission()
                alertsService.generateAlerts(weather: weatherService.weather, crops: store.crops, fields: store.fields)
            }
            .sheet(isPresented: $showAddCrop) { AddCropView() }
        }
    }

    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText).font(.title2).fontWeight(.black).foregroundColor(.white)
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill").font(.caption)
                        Text(locationService.placeName).font(.caption).fontWeight(.medium)
                    }.foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(auth.tier.badge).font(.title)
                    Text(auth.tier.rawValue).font(.system(size: 9, weight: .bold)).foregroundColor(.white.opacity(0.7))
                }
            }
            Text(dailyTip).font(.caption).italic().foregroundColor(.white.opacity(0.55)).lineLimit(2)
        }
        .padding(20)
        .background(FarmTheme.boldGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    @ViewBuilder
    private var criticalAlert: some View {
        if let alert = alertsService.alerts.first(where: { !$0.isRead && $0.severity == .critical }) {
            NavigationLink(destination: AlertsView()) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alert.title).font(.caption).fontWeight(.black)
                        Text(alert.message).font(.caption2).opacity(0.8).lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption)
                }
                .foregroundColor(.white).padding(14)
                .background(LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    @ViewBuilder
    private var upgradeBanner: some View {
        if auth.tier == .free {
            NavigationLink(destination: SubscriptionView()) {
                HStack(spacing: 12) {
                    Text("⭐").font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You're leaving money on the table").font(.caption).fontWeight(.black)
                        Text("Premium farmers get alerts that save R50,000+ in crop losses").font(.caption2).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("R99/mo").font(.caption2).fontWeight(.black)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(FarmTheme.gold).clipShape(Capsule())
                }
                .padding(14)
                .background(FarmTheme.gold.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(FarmTheme.gold.opacity(0.3), lineWidth: 1))
            }.buttonStyle(.plain)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatBadge(icon: "leaf.fill", value: "\(store.fields.count)", label: "Fields")
            StatBadge(icon: "carrot.fill", value: "\(store.crops.count)", label: "Crops", color: .orange)
            StatBadge(icon: "hare.fill", value: "\(store.livestock.count)", label: "Animals", color: .brown)
            StatBadge(icon: "shippingbox.fill", value: "\(store.harvests.count)", label: "Harvests", color: .purple)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What do you need?").font(.headline).fontWeight(.black)
            HStack(spacing: 12) {
                NavigationLink(destination: LeafScannerView()) {
                    QuickActionLabel(icon: "camera.viewfinder", label: "Scan", color: FarmTheme.primary)
                }
                Button { showAddCrop = true } label: {
                    QuickActionLabel(icon: "plus.circle.fill", label: "Add Crop", color: .orange)
                }
                NavigationLink(destination: FarmAnalyticsView()) {
                    QuickActionLabel(icon: "chart.bar.fill", label: "Analytics", color: .purple)
                }
                NavigationLink(destination: WeatherView()) {
                    QuickActionLabel(icon: "cloud.sun.fill", label: "Weather", color: .cyan)
                }
            }
        }
    }

    @ViewBuilder
    private var harvestCountdown: some View {
        let upcoming = store.crops
            .filter { $0.status == .growing || $0.status == .planted }
            .sorted { $0.expectedHarvestDate < $1.expectedHarvestDate }
            .prefix(3)
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("⏰ Harvest is coming").font(.headline).fontWeight(.black)
                ForEach(Array(upcoming)) { crop in
                    let days = Calendar.current.dateComponents([.day], from: Date(), to: crop.expectedHarvestDate).day ?? 0
                    FarmCard {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(days <= 7 ? Color.orange.opacity(0.15) : FarmTheme.primary.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Text(days <= 0 ? "🚨" : "🌾").font(.title3)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(crop.name).font(.subheadline).fontWeight(.bold)
                                Text(days < 0 ? "Overdue by \(abs(days)) days — harvest now!" : days == 0 ? "Today is the day! Go harvest!" : "\(days) days to go")
                                    .font(.caption).foregroundColor(days <= 0 ? .red : .secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var cropsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your Crops").font(.headline).fontWeight(.black)
                Spacer()
                NavigationLink(destination: CropsListView()) {
                    Text("See All →").font(.caption).fontWeight(.bold).foregroundColor(FarmTheme.primary)
                }
            }
            if store.crops.isEmpty {
                FarmCard {
                    VStack(spacing: 8) {
                        Text("🌱").font(.largeTitle)
                        Text("Your farm is a blank canvas").font(.subheadline).fontWeight(.bold)
                        Text("Add your first crop and watch your farm come alive")
                            .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity).padding(.vertical, 10)
                }
            } else {
                ForEach(store.crops.prefix(3)) { crop in
                    FarmCard {
                        HStack(spacing: 12) {
                            Circle().fill(cropColor(crop.status)).frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(crop.name).fontWeight(.bold)
                                Text(crop.status.rawValue.capitalized).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(crop.expectedHarvestDate, style: .date).font(.caption2).foregroundColor(FarmTheme.subtle)
                        }
                    }
                }
            }
        }
    }

    private func cropColor(_ s: CropStatus) -> Color {
        switch s {
        case .planned: return .gray; case .planted: return .blue; case .growing: return .green
        case .readyToHarvest: return .orange; case .harvested: return .brown
        }
    }
}

// MARK: - Farmer Profile
struct FarmerProfileView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Avatar
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(FarmTheme.boldGradient).frame(width: 90, height: 90)
                            Text("🌾").font(.system(size: 40))
                        }
                        Text(auth.currentUser?.name ?? "").font(.title3).fontWeight(.black)
                        Text(auth.currentUser?.email ?? "").font(.caption).foregroundColor(.secondary)
                        HStack(spacing: 6) {
                            Text(auth.tier.badge)
                            Text(auth.tier.rawValue).font(.caption2).fontWeight(.black)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(FarmTheme.primary.opacity(0.1))
                        .clipShape(Capsule())
                    }.padding(.top, 20)

                    // Menu
                    VStack(spacing: 0) {
                        profileRow(icon: "chart.bar.fill", label: "Farm Analytics", color: .purple, dest: FarmAnalyticsView())
                        Divider().padding(.leading, 52)
                        profileRow(icon: "creditcard.fill", label: "Subscription", color: .orange, dest: SubscriptionView())
                        Divider().padding(.leading, 52)
                        profileRow(icon: "leaf.fill", label: "My Fields", color: FarmTheme.primary, dest: FieldsListView())
                        Divider().padding(.leading, 52)
                        profileRow(icon: "carrot.fill", label: "My Crops", color: .orange, dest: CropsListView())
                        Divider().padding(.leading, 52)
                        profileRow(icon: "hare.fill", label: "My Livestock", color: .brown, dest: LivestockListView())
                        Divider().padding(.leading, 52)
                        profileRow(icon: "shippingbox.fill", label: "Harvests", color: .purple, dest: HarvestsListView())
                        Divider().padding(.leading, 52)
                        profileRow(icon: "banknote.fill", label: "Finances", color: .green, dest: FinancesView())
                        Divider().padding(.leading, 52)
                        profileRow(icon: "cloud.sun.fill", label: "Weather", color: .cyan, dest: WeatherView())
                    }
                    .background(FarmTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: FarmTheme.shadow, radius: 8, y: 3)

                    // Scan usage
                    scanUsageCard

                    Button { auth.logout() } label: {
                        Text("Sign Out")
                            .fontWeight(.black).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(FarmTheme.danger)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }.padding(.top, 10)
                }.padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Profile")
        }
    }

    private func profileRow<D: View>(icon: String, label: String, color: Color, dest: D) -> some View {
        NavigationLink(destination: dest) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 32, height: 32)
                    Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundColor(color)
                }
                Text(label).font(.subheadline).fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right").font(.caption2).foregroundColor(FarmTheme.subtle)
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
        }.buttonStyle(.plain)
    }

    private var scanUsageCard: some View {
        let used = auth.currentUser?.monthlyScanCount ?? 0
        let limit = auth.tier.scanLimit
        let limitText = limit == .max ? "Unlimited" : "\(limit)"
        return FarmCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "camera.viewfinder").foregroundColor(FarmTheme.primary)
                    Text("Scan Usage").font(.subheadline).fontWeight(.black)
                }
                HStack {
                    Text("\(used) / \(limitText) scans this month").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    if limit != .max {
                        NavigationLink(destination: SubscriptionView()) {
                            Text("Get More").font(.caption2).fontWeight(.black).foregroundColor(.orange)
                        }
                    }
                }
                if limit != .max {
                    ProgressView(value: Double(used), total: Double(limit))
                        .tint(used >= limit ? .red : FarmTheme.primary)
                }
            }
        }
    }
}

// MARK: - Basic Profile
struct ProfileView: View {
    @EnvironmentObject var auth: AuthService
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                ZStack {
                    Circle().fill(FarmTheme.boldGradient).frame(width: 90, height: 90)
                    Image(systemName: auth.isAdmin ? "shield.fill" : "person.fill")
                        .font(.system(size: 34)).foregroundColor(.white)
                }
                Text(auth.currentUser?.name ?? "").font(.title3).fontWeight(.black)
                Text(auth.currentUser?.email ?? "").font(.caption).foregroundColor(.secondary)
                Text(auth.currentUser?.role.rawValue.capitalized ?? "")
                    .font(.caption2).fontWeight(.black).foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(auth.isAdmin ? Color.orange : FarmTheme.primary)
                    .clipShape(Capsule())
                Spacer()
                Button { auth.logout() } label: {
                    Text("Sign Out")
                        .fontWeight(.black).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(FarmTheme.danger)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }.padding(.horizontal).padding(.bottom, 32)
            }
            .padding(.top, 40)
            .background(FarmTheme.background)
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Quick Action Button
private struct QuickActionLabel: View {
    let icon: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 42, height: 42)
                Image(systemName: icon).font(.system(size: 16, weight: .bold)).foregroundColor(color)
            }
            Text(label).font(.caption2).fontWeight(.semibold).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: FarmTheme.shadow, radius: 5, y: 2)
    }
}
