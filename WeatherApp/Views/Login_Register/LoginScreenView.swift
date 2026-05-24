import SwiftUI
import SwiftData

struct LoginScreenView: View {
    @Binding var userName: String
    @Binding var password: String
    @Binding var isRegisteredtapped: Bool
    @Binding var isLoggedIn: Bool
    @Binding var loggedInUser: String

    @Environment(\.modelContext) private var modelContext
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Welcome Back")
                .bold()
                .font(.title)
                .foregroundStyle(.black)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Username")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                TextField("Enter username", text: $userName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                SecureField("Enter password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }

            if let error = authVM.errorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, -6)
            }

          
            Spacer(minLength: 16)

            Button(action: login) {
                Text("Login")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
            .font(.title3)
            HStack {
                Spacer()
                Button {
                    isRegisteredtapped = true
                } label: {
                    Text("New user? \(Text("Sign Up").fontWeight(.semibold))")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }

        }
        .padding(28)
    }

    private func login() {
        let trimmed = userName.trimmingCharacters(in: .whitespaces)
        if authVM.login(username: trimmed, password: password, context: modelContext) {
            loggedInUser = trimmed
            isLoggedIn = true
        }
    }
}

#Preview("Empty") {
    LoginScreenView(
        userName: .constant(""),
        password: .constant(""),
        isRegisteredtapped: .constant(false),
        isLoggedIn: .constant(false),
        loggedInUser: .constant("")
    )
    .modelContainer(for: User.self, inMemory: true)
}

#Preview("Filled") {
    LoginScreenView(
        userName: .constant("akshay"),
        password: .constant("Secret@1"),
        isRegisteredtapped: .constant(false),
        isLoggedIn: .constant(false),
        loggedInUser: .constant("")
    )
    .modelContainer(for: User.self, inMemory: true)
}
