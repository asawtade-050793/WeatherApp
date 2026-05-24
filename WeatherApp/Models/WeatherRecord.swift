import Foundation
import SwiftData

@Model
final class WeatherRecord {
    var username: String
    var timestamp: Date
    var cityName: String
    var country: String
    var latitude: Double
    var longitude: Double
    var temperature: Double
    var feelsLike: Double
    var weatherDescription: String
    var weatherMain: String
    var weatherCode: Int
    var humidity: Int
    var pressure: Int
    var windSpeed: Double
    var windDeg: Int
    var visibility: Int
    var clouds: Int
    var sunriseTimestamp: Int
    var sunsetTimestamp: Int
    var timezone: Int
    var dt: Int

    init(
        username: String,
        timestamp: Date,
        cityName: String,
        country: String,
        latitude: Double,
        longitude: Double,
        temperature: Double,
        feelsLike: Double,
        weatherDescription: String,
        weatherMain: String,
        weatherCode: Int,
        humidity: Int,
        pressure: Int,
        windSpeed: Double,
        windDeg: Int,
        visibility: Int,
        clouds: Int,
        sunriseTimestamp: Int,
        sunsetTimestamp: Int,
        timezone: Int,
        dt: Int
    ) {
        self.username = username
        self.timestamp = timestamp
        self.cityName = cityName
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.weatherDescription = weatherDescription
        self.weatherMain = weatherMain
        self.weatherCode = weatherCode
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.windDeg = windDeg
        self.visibility = visibility
        self.clouds = clouds
        self.sunriseTimestamp = sunriseTimestamp
        self.sunsetTimestamp = sunsetTimestamp
        self.timezone = timezone
        self.dt = dt
    }
}

extension WeatherRecord {
    static func from(_ response: WeatherResponse, username: String, timestamp: Date = Date()) -> WeatherRecord {
        WeatherRecord(
            username: username,
            timestamp: timestamp,
            cityName: response.name,
            country: response.sys.country,
            latitude: response.coord.lat,
            longitude: response.coord.lon,
            temperature: response.main.temp,
            feelsLike: response.main.feelsLike,
            weatherDescription: response.weather.first?.description ?? "",
            weatherMain: response.weather.first?.main ?? "",
            weatherCode: response.weather.first?.id ?? 800,
            humidity: response.main.humidity,
            pressure: response.main.pressure,
            windSpeed: response.wind.speed,
            windDeg: response.wind.deg,
            visibility: response.visibility,
            clouds: response.clouds.all,
            sunriseTimestamp: response.sys.sunrise,
            sunsetTimestamp: response.sys.sunset,
            timezone: response.timezone,
            dt: response.dt
        )
    }
}
