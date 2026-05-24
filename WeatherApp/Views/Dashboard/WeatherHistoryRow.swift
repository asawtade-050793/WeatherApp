import SwiftUI

struct WeatherHistoryRow: View {
    let record: WeatherRecord

    private var iconAsset: String {
        weatherIconAsset(code: record.weatherCode, dt: record.dt, timezone: record.timezone)
    }
    private var sunriseTime: String {
        formatLocalDate(record.sunriseTimestamp, timezone: record.timezone, format: "HH:mm")
    }
    private var sunsetTime: String {
        formatLocalDate(record.sunsetTimestamp, timezone: record.timezone, format: "HH:mm")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                Text("\(record.cityName), \(record.country)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(formatLocalDate(record.dt, timezone: record.timezone, format: "MMM d, yyyy  HH:mm"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(iconAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(record.weatherDescription.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 35)
                    Text("\(formatTemp(record.temperature))°C")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(red: 0.2, green: 0.45, blue: 1.0))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "sunrise.fill")
                            .foregroundStyle(.orange)
                        Text(sunriseTime).font(.caption2)
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "sunset.fill")
                            .foregroundStyle(.orange)
                        Text(sunsetTime).font(.caption2)
                    }
                }
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
