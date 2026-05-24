import SwiftUI
import SwiftData

@MainActor
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var history: [WeatherRecord]
    @StateObject private var viewModel: WeatherViewModel
    @Binding var isLoggedIn: Bool
    let username: String

    init(isLoggedIn: Binding<Bool>, username: String) {
        _viewModel = StateObject(wrappedValue: WeatherViewModel())
        _isLoggedIn = isLoggedIn
        _history = Query(
            filter: #Predicate<WeatherRecord> { $0.username == username },
            sort: \WeatherRecord.timestamp,
            order: .reverse
        )
        self.username = username
    }

    init(viewModel: WeatherViewModel, isLoggedIn: Binding<Bool> = .constant(false), username: String = "") {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isLoggedIn = isLoggedIn
        _history = Query(
            filter: #Predicate<WeatherRecord> { $0.username == username },
            sort: \WeatherRecord.timestamp,
            order: .reverse
        )
        self.username = username
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.90, green: 0.94, blue: 0.99)
                    .ignoresSafeArea()

                Group {
                    if viewModel.isLoading && viewModel.weatherResponse == nil {
                        loadingView
                    } else {
                        mainScrollView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isLoggedIn = false
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .labelStyle(.iconOnly)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .task {
            print("[DashboardView] .task fired — starting weather fetch")
            viewModel.setModelContext(modelContext)
            viewModel.setUsername(username)
            await viewModel.fetchWeather()
            print("[DashboardView] .task completed")
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Fetching weather…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Main scroll content

    private var mainScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let weather = viewModel.weatherResponse {
                    headerView(weather)
                    WeatherMainCard(weather: weather)
                    SunriseSunsetCard(weather: weather)
                } else if let msg = viewModel.errorMessage {
                    errorView(msg)
                }

                if !history.isEmpty {
                    recentViewsSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.fetchWeather()
        }
    }

    // MARK: - Header

    private func headerView(_ weather: WeatherResponse) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "mappin.and.ellipse")
                        .fontWeight(.semibold)
                    Text("\(weather.name), \(weather.sys.country)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Text(formatCoordinate(lat: weather.coord.lat, lon: weather.coord.lon))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 22)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("Last updated")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                Text(formatLocalDate(weather.dt, timezone: weather.timezone, format: "MMM d, yyyy HH:mm"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 6)
    }

    // MARK: - Recent Views

    private var recentViewsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 7) {
                    Image(systemName: "clock.arrow.circlepath")
                        .fontWeight(.semibold)
                    Text("Recent Views")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                Spacer()

                NavigationLink {
                    WeatherHistoryView(username: username)
                } label: {
                    HStack(spacing: 4) {
                        Text("History")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.blue)
                }
            }

            VStack(spacing: 8) {
                ForEach(history.prefix(2)) { record in
                    WeatherHistoryRow(record: record)
                }
            }
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button {
                Task { await viewModel.fetchWeather() }
            } label: {
                Text("Retry")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(32)
    }
}

// MARK: - Previews

#Preview("Dashboard – Loading") {
    let vm = WeatherViewModel()
    vm.isLoading = true
    return DashboardView(viewModel: vm, isLoggedIn: .constant(true))
        .modelContainer(for: WeatherRecord.self, inMemory: true)
}

#Preview("Dashboard – Error") {
    let vm = WeatherViewModel()
    vm.errorMessage = "Location access denied. Please enable it in Settings → Privacy → Location Services."
    return DashboardView(viewModel: vm, isLoggedIn: .constant(true))
        .modelContainer(for: WeatherRecord.self, inMemory: true)
}
