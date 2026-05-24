import SwiftUI
import SwiftData

struct WeatherHistoryView: View {
    @Query private var history: [WeatherRecord]

    init(username: String) {
        _history = Query(
            filter: #Predicate<WeatherRecord> { $0.username == username },
            sort: \WeatherRecord.timestamp,
            order: .reverse
        )
    }

    var body: some View {
        ZStack {
            Color(red: 0.90, green: 0.94, blue: 0.99)
                .ignoresSafeArea()

            if history.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                    Text("No history yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(history) { record in
                            WeatherHistoryRow(record: record)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle("Weather History")
        .navigationBarTitleDisplayMode(.inline)
    }
}
