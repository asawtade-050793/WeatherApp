import SwiftUI

struct WeatherMainCard: View {
    let weather: WeatherResponse

    private var code: Int { weather.weather.first?.id ?? 800 }
    private var bgAsset: String { backgroundAsset(code: code, dt: weather.dt, timezone: weather.timezone) }
    private var iconAsset: String { weatherIconAsset(code: code, dt: weather.dt, timezone: weather.timezone) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                Image(bgAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: 240)
                    .clipped()
                    .overlay(Color.black.opacity(0.32))

                VStack(alignment: .leading, spacing: 4) {
                    Image(iconAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 62, height: 62)

                    Text("\(formatTemp(weather.main.temp))°C")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text((weather.weather.first?.description ?? "").capitalized)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("Feels like \(formatTemp(weather.main.feelsLike))°C")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }
                .padding(.leading, 16)
                .padding(.vertical, 20)
                .frame(width: geo.size.width, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

