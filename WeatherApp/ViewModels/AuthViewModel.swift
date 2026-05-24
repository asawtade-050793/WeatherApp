import Foundation
import Combine
import SwiftData

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var errorMessage: String?

    func login(username: String, password: String, context: ModelContext) -> Bool {
        errorMessage = nil
        let trimmed = username.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            errorMessage = "Please enter your username."
            return false
        }
        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return false
        }

        let predicate = #Predicate<User> { $0.username == trimmed }
        let users = (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []

        guard let user = users.first else {
            errorMessage = "No account found for '\(trimmed)'."
            return false
        }
        guard user.passwordHash == hashPassword(password) else {
            errorMessage = "Incorrect password."
            return false
        }
        return true
    }

    func register(username: String, password: String, confirmPassword: String, context: ModelContext) -> Bool {
        errorMessage = nil
        let trimmed = username.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            errorMessage = "Username cannot be empty."
            return false
        }
        if let failedRule = validatePassword(password) {
            errorMessage = failedRule.description
            return false
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        let predicate = #Predicate<User> { $0.username == trimmed }
        let existing = (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []
        guard existing.isEmpty else {
            errorMessage = "Username '\(trimmed)' is already taken."
            return false
        }

        let user = User(username: trimmed, passwordHash: hashPassword(password))
        context.insert(user)
        try? context.save()
        return true
    }
}
