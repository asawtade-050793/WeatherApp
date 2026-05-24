import Combine
import Foundation
import SwiftData
internal import _LocationEssentials

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherResponse: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let locationManager = LocationManager()
    private var modelContext: ModelContext?
    private var currentUsername = ""

    init(previewResponse: WeatherResponse? = nil) {
        weatherResponse = previewResponse
        print("[WeatherViewModel] Initialized. Preview data: \(previewResponse != nil)")
    }

    func setModelContext(_ context: ModelContext) {
        modelContext = context
        print("[WeatherViewModel] ModelContext set")
    }

    func setUsername(_ username: String) {
        currentUsername = username
    }

    func fetchWeather() async {
        guard !isLoading else {
            print("[WeatherViewModel] fetchWeather() called while already in progress — skipping")
            return
        }
        print("[WeatherViewModel] fetchWeather() start")
        isLoading = true
        errorMessage = nil

        do {
            print("[WeatherViewModel] Step 1 — requesting location")
            let location = try await locationManager.requestLocation()
            print("[WeatherViewModel] Step 2 — got location lat=\(location.coordinate.latitude) lon=\(location.coordinate.longitude)")

            print("[WeatherViewModel] Step 3 — calling weather API")
            let response = try await WeatherService.shared.fetchWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
            print("[WeatherViewModel] Step 4 — API response received: \(response.name), \(response.main.temp)K")

            weatherResponse = response
            saveRecord(from: response)
            print("[WeatherViewModel] Step 5 — done. isLoading → false")
        } catch {
            print("[WeatherViewModel] fetchWeather() FAILED: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func saveRecord(from response: WeatherResponse) {
        guard let context = modelContext else {
            print("[WeatherViewModel] saveRecord() skipped — no modelContext")
            return
        }
        let record = WeatherRecord.from(response, username: currentUsername)
        context.insert(record)
        do {
            try context.save()
            print("[WeatherViewModel] WeatherRecord saved to SwiftData")
        } catch {
            print("[WeatherViewModel] Failed to save WeatherRecord: \(error)")
        }
    }
}
