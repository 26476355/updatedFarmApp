import Foundation

class WeatherService: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Replace with your OpenWeatherMap API key
    private let apiKey = "<y>"

    func fetchWeather(for city: String) {
        guard let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(encoded)&appid=\(apiKey)&units=metric") else { return }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else { return }
                self?.weather = try? JSONDecoder().decode(WeatherResponse.self, from: data)
            }
        }.resume()
    }
}
