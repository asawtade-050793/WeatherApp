import SwiftUI
import SwiftData

struct RegisterScreenView: View {
    @Binding var isRegisteredtapped: Bool

    @Environment(\.modelContext) private var modelContext
    @StateObject private var authVM = AuthViewModel()

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showSuccess = false

    private var ruleStatus: [(rule: PasswordRule, met: Bool)] {
        PasswordRule.allCases.map { ($0, $0.isSatisfied(by: password)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Create Account")
                .bold()
                .font(.title)
                .foregroundStyle(.black)
                .padding(.bottom, 4)

            fieldSection(label: "Username") {
                TextField("Enter username", text: $username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .fieldStyle()
            }

            fieldSection(label: "Password") {
                SecureField("Enter password", text: $password)
                    .fieldStyle()

                if !password.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(ruleStatus, id: \.rule) { item in
                            RequirementRow(met: item.met, text: item.rule.description)
                        }
                    }
                    .padding(.top, 4)
                    .padding(.leading, 2)
                }
            }

            fieldSection(label: "Confirm Password") {
                SecureField("Re-enter password", text: $confirmPassword)
                    .fieldStyle()

                if !confirmPassword.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: password == confirmPassword
                              ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(password == confirmPassword ? .green : .red)
                        Text(password == confirmPassword ? "Passwords match" : "Passwords do not match")
                    }
                    .font(.caption)
                    .padding(.top, 4)
                    .padding(.leading, 2)
                }
            }

            if let error = authVM.errorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, -6)
            }

            Button(action: register) {
                Text("Register")
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
                    isRegisteredtapped = false
                } label: {
                    Text("Already have an account? \(Text("Sign In").fontWeight(.semibold))")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
        .padding(28)
        .alert("Account Created", isPresented: $showSuccess) {
            Button("Sign In") { isRegisteredtapped = false }
        } message: {
            Text("Welcome, \(username)! Your account is ready.")
        }
    }

    private func register() {
        if authVM.register(username: username, password: password, confirmPassword: confirmPassword, context: modelContext) {
            showSuccess = true
        }
    }
}

// MARK: - Helpers

private extension View {
    func fieldStyle() -> some View {
        self
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

@ViewBuilder
private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.black)
        content()
    }
}

struct RequirementRow: View {
    let met: Bool
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(met ? .green : Color(.systemGray3))
            Text(text)
                .font(.caption)
                .foregroundStyle(met ? .primary : .secondary)
        }
    }
}

#Preview("Register") {
    ScrollView {
        RegisterScreenView(isRegisteredtapped: .constant(true))
    }
    .modelContainer(for: User.self, inMemory: true)
}
