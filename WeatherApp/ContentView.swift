import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var loggedInUser = ""

    var body: some View {
        if isLoggedIn {
            DashboardView(isLoggedIn: $isLoggedIn, username: loggedInUser)
        } else {
            LoginView(isLoggedIn: $isLoggedIn, loggedInUser: $loggedInUser)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, WeatherRecord.self, User.self], inMemory: true)
}
