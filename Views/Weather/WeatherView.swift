import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var weatherService: WeatherService
    @State private var city = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(FarmTheme.subtle)
                            TextField("Enter city name", text: $city)
                        }
                        .padding(12)
                        .background(FarmTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: FarmTheme.shadow, radius: 4, y: 2)

                        Button {
                            weatherService.fetchWeather(for: city)
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(FarmTheme.primary)
                        }
                    }

                    if weatherService.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if let error = weatherService.errorMessage {
                        FarmCard {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    } else if let w = weatherService.weather {
                        weatherCard(w)
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "cloud.sun.fill")
                                .font(.system(size: 48))
                                .foregroundColor(FarmTheme.accent)
                            Text("Search for a city to see weather")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                    }

                    Spacer()
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Weather")
        }
    }

    private func weatherCard(_ w: WeatherResponse) -> some View {
        VStack(spacing: 16) {
            Text(w.name)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            Text("\(w.main.temp, specifier: "%.0f")°C")
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.white)
            if let info = w.weather.first {
                Text(info.description.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            HStack(spacing: 24) {
                WeatherStat(icon: "humidity", value: "\(w.main.humidity)%", label: "Humidity")
                WeatherStat(icon: "wind", value: "\(w.wind.speed) m/s", label: "Wind")
                WeatherStat(icon: "gauge.medium", value: "\(w.main.pressure)", label: "hPa")
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(FarmTheme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct WeatherStat: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
        }
        .foregroundColor(.white.opacity(0.9))
    }
}
