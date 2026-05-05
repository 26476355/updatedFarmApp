import CoreLocation
import SwiftUI

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var location: CLLocation?
    @Published var placeName: String = "Locating..."
    @Published var authStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        location = loc
        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            if let p = placemarks?.first {
                self?.placeName = [p.locality, p.administrativeArea, p.country]
                    .compactMap { $0 }.joined(separator: ", ")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        placeName = "Location unavailable"
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
