import XCTest
import SwiftData
@testable import WeatherApp

// MARK: - WeatherHelpers

final class WeatherHelpersTests: XCTestCase {

    func testKelvinToCelsius() {
        XCTAssertEqual(kelvinToCelsius(273.15), 0, accuracy: 0.001)
        XCTAssertEqual(kelvinToCelsius(373.15), 100, accuracy: 0.001)
        XCTAssertEqual(kelvinToCelsius(0), -273.15, accuracy: 0.001)
    }

    func testFormatTemp() {
        XCTAssertEqual(formatTemp(273.15), "0.0")
        XCTAssertEqual(formatTemp(274.15), "1.0")
        XCTAssertEqual(formatTemp(373.15), "100.0")
    }

    func testWindDirection() {
        XCTAssertEqual(windDirection(degrees: 0),   "N")
        XCTAssertEqual(windDirection(degrees: 90),  "E")
        XCTAssertEqual(windDirection(degrees: 180), "S")
        XCTAssertEqual(windDirection(degrees: 270), "W")
        XCTAssertEqual(windDirection(degrees: 360), "N")
    }

    func testIsRainy() {
        XCTAssertTrue(isRainy(code: 200))   // thunderstorm
        XCTAssertTrue(isRainy(code: 300))   // drizzle
        XCTAssertTrue(isRainy(code: 500))   // rain
        XCTAssertFalse(isRainy(code: 600))  // snow
        XCTAssertFalse(isRainy(code: 800))  // clear
    }

    func testIsDaytime() {
        // 2024-01-01 12:00 UTC — noon, daytime in UTC+0
        XCTAssertTrue(isDaytime(dt: 1704110400, timezone: 0))
        // 2024-01-01 00:00 UTC — midnight, night in UTC+0
        XCTAssertFalse(isDaytime(dt: 1704067200, timezone: 0))
        // 2024-01-01 23:00 UTC — shifts to 01:00 local in UTC+2, still night
        XCTAssertFalse(isDaytime(dt: 1704153600, timezone: 7200))
    }

    func testFormatCoordinate() {
        XCTAssertEqual(formatCoordinate(lat: 44.34, lon: 10.99), "44.34° N, 10.99° E")
        XCTAssertEqual(formatCoordinate(lat: -33.87, lon: 151.21), "33.87° S, 151.21° E")
        XCTAssertEqual(formatCoordinate(lat: 0, lon: -74.01), "0.00° N, 74.01° W")
    }

    func testUtcOffsetString() {
        XCTAssertEqual(utcOffsetString(timezone: 7200),   "UTC+2")
        XCTAssertEqual(utcOffsetString(timezone: -18000), "UTC-5")
        XCTAssertEqual(utcOffsetString(timezone: 0),      "UTC+0")
    }
}

// MARK: - AuthHelpers

final class AuthHelpersTests: XCTestCase {

    func testHashPasswordConsistency() {
        XCTAssertEqual(hashPassword("Secret@1"), hashPassword("Secret@1"))
    }

    func testHashPasswordCaseSensitive() {
        XCTAssertNotEqual(hashPassword("Secret@1"), hashPassword("secret@1"))
    }

    func testHashPasswordLength() {
        XCTAssertEqual(hashPassword("any").count, 64) // SHA-256 = 64 hex chars
    }

    func testPasswordRuleMinLength() {
        XCTAssertFalse(PasswordRule.minLength.isSatisfied(by: "Ab@1"))
        XCTAssertTrue(PasswordRule.minLength.isSatisfied(by: "Ab@12345"))
    }

    func testPasswordRuleUppercase() {
        XCTAssertFalse(PasswordRule.uppercase.isSatisfied(by: "abc123@!"))
        XCTAssertTrue(PasswordRule.uppercase.isSatisfied(by: "Abc123@!"))
    }

    func testPasswordRuleLowercase() {
        XCTAssertFalse(PasswordRule.lowercase.isSatisfied(by: "ABC123@!"))
        XCTAssertTrue(PasswordRule.lowercase.isSatisfied(by: "ABc123@!"))
    }

    func testPasswordRuleNumber() {
        XCTAssertFalse(PasswordRule.number.isSatisfied(by: "Abcdef@!"))
        XCTAssertTrue(PasswordRule.number.isSatisfied(by: "Abcde1@!"))
    }

    func testPasswordRuleSpecialChar() {
        XCTAssertFalse(PasswordRule.specialChar.isSatisfied(by: "Abcde123"))
        XCTAssertTrue(PasswordRule.specialChar.isSatisfied(by: "Abcde12!"))
    }

    func testValidatePasswordPassesForValidPassword() {
        XCTAssertNil(validatePassword("Secret@1"))
    }

    func testValidatePasswordFailsForShortPassword() {
        XCTAssertEqual(validatePassword("Ab@1"), .minLength)
    }

    func testValidatePasswordReturnsFirstFailingRule() {
        XCTAssertEqual(validatePassword("abcdef@1"), .uppercase)
    }
}

// MARK: - AuthViewModel

@MainActor
final class AuthViewModelTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!
    var vm: AuthViewModel!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: User.self, configurations: config)
        context = ModelContext(container)
        vm = AuthViewModel()
    }

    override func tearDown() async throws {
        container = nil
        context = nil
        vm = nil
    }

    // MARK: Register

    func testRegisterSuccess() {
        XCTAssertTrue(vm.register(username: "akshay", password: "Secret@1", confirmPassword: "Secret@1", context: context))
        XCTAssertNil(vm.errorMessage)
    }

    func testRegisterEmptyUsername() {
        XCTAssertFalse(vm.register(username: "  ", password: "Secret@1", confirmPassword: "Secret@1", context: context))
        XCTAssertEqual(vm.errorMessage, "Username cannot be empty.")
    }

    func testRegisterWeakPassword() {
        XCTAssertFalse(vm.register(username: "akshay", password: "weak", confirmPassword: "weak", context: context))
        XCTAssertNotNil(vm.errorMessage)
    }

    func testRegisterPasswordMismatch() {
        XCTAssertFalse(vm.register(username: "akshay", password: "Secret@1", confirmPassword: "Secret@2", context: context))
        XCTAssertEqual(vm.errorMessage, "Passwords do not match.")
    }

    func testRegisterDuplicateUsername() {
        _ = vm.register(username: "akshay", password: "Secret@1", confirmPassword: "Secret@1", context: context)
        XCTAssertFalse(vm.register(username: "akshay", password: "Secret@1", confirmPassword: "Secret@1", context: context))
        XCTAssertNotNil(vm.errorMessage)
    }

    // MARK: Login

    func testLoginSuccess() {
        _ = vm.register(username: "akshay", password: "Secret@1", confirmPassword: "Secret@1", context: context)
        vm.errorMessage = nil
        XCTAssertTrue(vm.login(username: "akshay", password: "Secret@1", context: context))
        XCTAssertNil(vm.errorMessage)
    }

    func testLoginEmptyUsername() {
        XCTAssertFalse(vm.login(username: "", password: "Secret@1", context: context))
        XCTAssertEqual(vm.errorMessage, "Please enter your username.")
    }

    func testLoginEmptyPassword() {
        XCTAssertFalse(vm.login(username: "akshay", password: "", context: context))
        XCTAssertEqual(vm.errorMessage, "Please enter your password.")
    }

    func testLoginUnknownUser() {
        XCTAssertFalse(vm.login(username: "nobody", password: "Secret@1", context: context))
        XCTAssertNotNil(vm.errorMessage)
    }

    func testLoginWrongPassword() {
        _ = vm.register(username: "akshay", password: "Secret@1", confirmPassword: "Secret@1", context: context)
        XCTAssertFalse(vm.login(username: "akshay", password: "Wrong@123", context: context))
        XCTAssertEqual(vm.errorMessage, "Incorrect password.")
    }

    func testLoginTrimsWhitespace() {
        _ = vm.register(username: "akshay", password: "Secret@1", confirmPassword: "Secret@1", context: context)
        vm.errorMessage = nil
        XCTAssertTrue(vm.login(username: "  akshay  ", password: "Secret@1", context: context))
    }
}
