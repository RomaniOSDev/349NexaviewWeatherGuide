import CoreLocation
import Foundation

struct LiveWeatherSnapshot: Equatable {
    let temperatureC: Double
    let windKmh: Double
    let fetchedAt: Date
    let latitude: Double
    let longitude: Double

    func temperature(in units: PreferredUnits) -> Double {
        UnitBridge.temperature(temperatureC, from: .metric, to: units)
    }

    func wind(in units: PreferredUnits) -> Double {
        UnitBridge.wind(windKmh, from: .metric, to: units)
    }

    func chill(in units: PreferredUnits) -> Double {
        WindChillMath.chill(
            temperature: temperature(in: units),
            windSpeed: wind(in: units),
            units: units
        )
    }
}

enum LiveWeatherError: LocalizedError {
    case locationDenied
    case locationUnavailable
    case network
    case badResponse

    var errorDescription: String? {
        switch self {
        case .locationDenied:
            return "Location access is off. Enable it in Settings to pull live air and wind."
        case .locationUnavailable:
            return "Could not read your current location."
        case .network:
            return "Live weather request failed. Check the connection and try again."
        case .badResponse:
            return "Live weather response was incomplete."
        }
    }
}

@MainActor
final class LiveWeatherService: NSObject, ObservableObject {
    @Published var snapshot: LiveWeatherSnapshot?
    @Published var isLoading = false
    @Published var lastError: String?

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            let location = try await requestLocation()
            let weather = try await fetchOpenMeteo(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            snapshot = weather
        } catch let error as LiveWeatherError {
            lastError = error.localizedDescription
        } catch {
            lastError = LiveWeatherError.network.localizedDescription
        }
    }

    private func requestLocation() async throws -> CLLocation {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            try await waitForAuthorizationChange()
            return try await requestLocation()
        case .denied, .restricted:
            throw LiveWeatherError.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            throw LiveWeatherError.locationUnavailable
        }
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    private func waitForAuthorizationChange() async throws {
        for _ in 0..<40 {
            try await Task.sleep(nanoseconds: 100_000_000)
            let status = locationManager.authorizationStatus
            if status != .notDetermined { return }
        }
        throw LiveWeatherError.locationDenied
    }

    private func fetchOpenMeteo(latitude: Double, longitude: Double) async throws -> LiveWeatherSnapshot {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,wind_speed_10m"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        guard let url = components.url else { throw LiveWeatherError.network }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw LiveWeatherError.network
        }
        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        guard let temp = decoded.current?.temperature_2m,
              let wind = decoded.current?.wind_speed_10m else {
            throw LiveWeatherError.badResponse
        }
        return LiveWeatherSnapshot(
            temperatureC: temp,
            windKmh: wind,
            fetchedAt: Date(),
            latitude: latitude,
            longitude: longitude
        )
    }
}

extension LiveWeatherService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else {
                locationContinuation?.resume(throwing: LiveWeatherError.locationUnavailable)
                locationContinuation = nil
                return
            }
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: LiveWeatherError.locationUnavailable)
            locationContinuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {}
}

private struct OpenMeteoResponse: Decodable {
    struct Current: Decodable {
        let temperature_2m: Double?
        let wind_speed_10m: Double?
    }

    let current: Current?
}
