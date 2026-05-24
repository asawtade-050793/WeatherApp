import SwiftUI
import SwiftData

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var loggedInUser: String
    @State private var userName = ""
    @State private var password = ""
    @State private var isRegisterMode = false

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ZStack(alignment: .top) {
                    Image("background")
                        .resizable()
                        .frame(height: 400)
                        .offset(y: -65)

                    VStack {
                        if isRegisterMode {
                            RegisterScreenView(isRegisteredtapped: $isRegisterMode)
                                .padding(.bottom, 300)
                        } else {
                            LoginScreenView(
                                userName: $userName,
                                password: $password,
                                isRegisteredtapped: $isRegisterMode,
                                isLoggedIn: $isLoggedIn,
                                loggedInUser: $loggedInUser
                            )
                        }
                    }
                    .offset(y: 300)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview("Login") {
    LoginView(isLoggedIn: .constant(false), loggedInUser: .constant(""))
        .modelContainer(for: User.self, inMemory: true)
}
