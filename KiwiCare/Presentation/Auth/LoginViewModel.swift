//
//  LoginViewModel.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

import Observation
import Foundation

@Observable
final class LoginViewModel {
#if DEBUG
    var email = "customer@kiwicare.test"
    var password = "Kiwi@1234"
#else
    var email = ""
    var password = ""
#endif
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    private let signIn: SignInUseCase
    private let onSignedIn: (AuthSession) -> Void

    init(signIn: SignInUseCase, onSignedIn: @escaping (AuthSession) -> Void) {
        self.signIn = signIn
        self.onSignedIn = onSignedIn
    }

    func submit() async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await signIn.execute(email: email, password: password)
            onSignedIn(session)
        } catch let error as AuthError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = Self.message(for: .unknown)
        }
    }

    private static func message(for error: AuthError) -> String {
        switch error {
        case .invalidEmail:
            String(localized: "Please enter a valid email address.")
        case .invalidPassword:
            String(localized: "Password must be at least 8 characters with uppercase, lowercase, a number and a symbol.")
        case .invalidCredentials:
            String(localized: "Incorrect email or password.")
        case .network:
            String(localized: "Unable to connect. Please check your network.")
        case .sessionExpired, .unknown:
            String(localized: "Something went wrong. Please try again.")
        }
    }
}
