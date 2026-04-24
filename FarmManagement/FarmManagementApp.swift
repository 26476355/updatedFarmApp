import SwiftUI

@main
struct FarmManagementApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var weatherService = WeatherService()

    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                FieldsListView()
                    .tabItem { Label("Fields", systemImage: "leaf.fill") }
                CropsListView()
                    .tabItem { Label("Crops", systemImage: "carrot.fill") }
                LivestockListView()
                    .tabItem { Label("Livestock", systemImage: "hare.fill") }
                FinancesView()
                    .tabItem { Label("Finances", systemImage: "chart.bar.fill") }
            }
            .tint(FarmTheme.primary)
            .environmentObject(store)
            .environmentObject(weatherService)
        }
    }
}
