//
//  SignInUseCase.swift
//  KiwiCare
//

import Foundation

protocol SignInUseCase {
    func execute(email: String, password: String) async throws -> AuthSession
}

/// Normalises and validates credentials before asking the repository to sign in.
struct DefaultSignInUseCase: SignInUseCase {
    let repository: AuthRepository

    func execute(email: String, password: String) async throws -> AuthSession {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard EmailValidator.isValid(email) else { throw AuthError.invalidEmail }
        guard PasswordPolicy.isValid(password) else { throw AuthError.invalidPassword }

        return try await repository.signIn(email: email, password: password)
    }
}
