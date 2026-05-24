import SwiftUI

struct SunriseSunsetCard: View {
    let weather: WeatherResponse

    private var sunriseTime: String {
        formatLocalDate(weather.sys.sunrise, timezone: weather.timezone, format: "HH:mm")
    }
    private var sunsetTime: String {
        formatLocalDate(weather.sys.sunset, timezone: weather.timezone, format: "HH:mm")
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "sunrise.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Sunrise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(sunriseTime)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            SunArcShape()
                .frame(width: 100, height: 44)

            Spacer()

            HStack(spacing: 10) {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("Sunset")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(sunsetTime)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Image(systemName: "sunset.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Arc drawing

struct SunArcShape: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height
            let r  = size.height - 2

            var arc = Path()
            arc.addArc(center: CGPoint(x: cx, y: cy),
                       radius: r,
                       startAngle: .degrees(180),
                       endAngle:   .degrees(0),
                       clockwise:  false)

            context.stroke(arc,
                           with: .color(.orange.opacity(0.55)),
                           style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
        }
        .overlay(alignment: .top) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 18))
                .foregroundStyle(.yellow)
                .offset(y: -2)
        }
    }
}
