import Foundation

struct WeatherResponse: Codable {
    let main: WeatherMain
    let weather: [WeatherInfo]
    let wind: Wind
    let name: String
}

struct WeatherMain: Codable {
    let temp: Double
    let humidity: Int
    let pressure: Int
}

struct WeatherInfo: Codable {
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
}
