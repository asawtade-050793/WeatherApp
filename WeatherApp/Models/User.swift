import Foundation
import SwiftData

@Model
final class User {
    var username: String
    var passwordHash: String
    var createdAt: Date

    init(username: String, passwordHash: String) {
        self.username = username
        self.passwordHash = passwordHash
        self.createdAt = Date()
    }
}
