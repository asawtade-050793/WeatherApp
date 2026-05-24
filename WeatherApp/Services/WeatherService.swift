import Foundation

struct WeatherService {
    static let shared = WeatherService()
    private init() {}

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard var components = URLComponents(string: Config.baseURL) else {
            print("[WeatherService] Bad base URL in Config")
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: Config.openWeatherAPIKey)
        ]
        guard let url = components.url else {
            print("[WeatherService] Could not build URL from components")
            throw URLError(.badURL)
        }

        print("[WeatherService] GET \(url.absoluteString.replacingOccurrences(of: Config.openWeatherAPIKey, with: "***"))")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            print("[WeatherService] Response is not HTTPURLResponse")
            throw URLError(.badServerResponse)
        }

        print("[WeatherService] HTTP \(http.statusCode) — \(data.count) bytes")

        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "<unreadable>"
            print("[WeatherService] Non-200 response body: \(body)")
            throw URLError(.badServerResponse)
        }

        do {
            let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
            print("[WeatherService] Decoded: \(decoded.name), \(decoded.sys.country)")
            return decoded
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? "<unreadable>"
            print("[WeatherService] JSON decode failed: \(error)\nRaw: \(raw)")
            throw error
        }
    }
}
