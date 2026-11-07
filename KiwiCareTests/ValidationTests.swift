//
//  ValidationTests.swift
//  KiwiCareTests
//

import Testing
@testable import KiwiCare

@MainActor
struct ValidationTests {
    @Test(arguments: ["a@b.com", "first.last@kiwicare.co.nz"])
    func validEmails(_ email: String) {
        #expect(EmailValidator.isValid(email))
    }

    @Test(arguments: ["", "not-an-email", "a@b", "a b@c.com", "@b.com"])
    func invalidEmails(_ email: String) {
        #expect(!EmailValidator.isValid(email))
    }

    @Test(arguments: ["Pass@1234", "Abcdef1!"])
    func validPasswords(_ password: String) {
        #expect(PasswordPolicy.isValid(password))
    }

    @Test(arguments: ["short1!", "alllower1!", "ALLUPPER1!", "NoNumber!", "NoSymbol1"])
    func invalidPasswords(_ password: String) {
        #expect(!PasswordPolicy.isValid(password))
    }
}
