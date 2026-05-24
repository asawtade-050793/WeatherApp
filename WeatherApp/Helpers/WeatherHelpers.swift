import Foundation

func kelvinToCelsius(_ kelvin: Double) -> Double {
    kelvin - 273.15
}

func formatTemp(_ kelvin: Double) -> String {
    String(format: "%.1f", kelvinToCelsius(kelvin))
}

func isRainy(code: Int) -> Bool {
    (200...232).contains(code) || (300...321).contains(code) || (500...531).contains(code)
}

func localHour(dt: Int, timezone: Int) -> Int {
    let date = Date(timeIntervalSince1970: TimeInterval(dt))
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: timezone) ?? .current
    return cal.component(.hour, from: date)
}

func isDaytime(dt: Int, timezone: Int) -> Bool {
    let h = localHour(dt: dt, timezone: timezone)
    return h >= 6 && h < 18
}

func weatherIconAsset(code: Int, dt: Int, timezone: Int) -> String {
    if isRainy(code: code) { return "rain" }
    return isDaytime(dt: dt, timezone: timezone) ? "sun" : "mood"
}

func backgroundAsset(code: Int, dt: Int, timezone: Int) -> String {
    if isRainy(code: code) { return "rain" }
    return isDaytime(dt: dt, timezone: timezone) ? "background_day" : "background_night"
}

func formatLocalDate(_ timestamp: Int, timezone: Int, format: String) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let fmt = DateFormatter()
    fmt.timeZone = TimeZone(secondsFromGMT: timezone)
    fmt.dateFormat = format
    return fmt.string(from: date)
}

func formatCoordinate(lat: Double, lon: Double) -> String {
    let latDir = lat >= 0 ? "N" : "S"
    let lonDir = lon >= 0 ? "E" : "W"
    return String(format: "%.2f° %@, %.2f° %@", abs(lat), latDir, abs(lon), lonDir)
}
