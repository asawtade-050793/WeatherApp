import CryptoKit
import Foundation

func hashPassword(_ password: String) -> String {
    SHA256.hash(data: Data(password.utf8))
        .map { String(format: "%02x", $0) }
        .joined()
}

enum PasswordRule: CaseIterable {
    case minLength, uppercase, lowercase, number, specialChar

    var description: String {
        switch self {
        case .minLength:    return "At least 8 characters"
        case .uppercase:    return "At least 1 uppercase letter (A-Z)"
        case .lowercase:    return "At least 1 lowercase letter (a-z)"
        case .number:       return "At least 1 number (0-9)"
        case .specialChar:  return "At least 1 special character (!@#$%...)"
        }
    }

    func isSatisfied(by password: String) -> Bool {
        switch self {
        case .minLength:   return password.count >= 8
        case .uppercase:   return password.contains(where: \.isUppercase)
        case .lowercase:   return password.contains(where: \.isLowercase)
        case .number:      return password.contains(where: \.isNumber)
        case .specialChar:
            let specials = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?~`\\")
            return password.unicodeScalars.contains(where: { specials.contains($0) })
        }
    }
}

func validatePassword(_ password: String) -> PasswordRule? {
    PasswordRule.allCases.first { !$0.isSatisfied(by: password) }
}
