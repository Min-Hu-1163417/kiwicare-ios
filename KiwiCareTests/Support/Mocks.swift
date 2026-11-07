//
//  Mocks.swift
//  KiwiCareTests
//
//  Shared test doubles.
//

import Foundation
@testable import KiwiCare

// MARK: - Repositories

@MainActor
final class MockAuthRepository: AuthRepository {
    var signInResult: Result<AuthSession, Error> = .success(.stub)
    var restoreResult: Result<AuthSession?, Error> = .success(nil)

    private(set) var signInCalls: [(email: String, password: String)] = []
    private(set) var signOutCallCount = 0

    func signIn(email: String, password: String) async throws -> AuthSession {
        signInCalls.append((email, password))
        return try signInResult.get()
    }

    func restoreSession() async throws -> AuthSession? {
        try restoreResult.get()
    }

    func signOut() {
        signOutCallCount += 1
    }
}

// MARK: - Use cases

@MainActor
final class MockSignInUseCase: SignInUseCase {
    var result: Result<AuthSession, Error> = .success(.stub)
    var delay: Duration?
    private(set) var calls: [(email: String, password: String)] = []

    func execute(email: String, password: String) async throws -> AuthSession {
        calls.append((email, password))
        if let delay { try await Task.sleep(for: delay) }
        return try result.get()
    }
}

@MainActor
final class MockRestoreSessionUseCase: RestoreSessionUseCase {
    var result: Result<AuthSession?, Error> = .success(nil)

    func execute() async throws -> AuthSession? {
        try result.get()
    }
}

@MainActor
final class MockSignOutUseCase: SignOutUseCase {
    private(set) var callCount = 0

    func execute() {
        callCount += 1
    }
}

// MARK: - Data

@MainActor
final class MockHTTPClient: HTTPClient {
    /// Responses keyed by endpoint path, e.g. "auth/login", "user".
    var responses: [String: Result<Any, Error>] = [:]
    private(set) var requestedPaths: [String] = []

    func send<R: Decodable>(_ endpoint: Endpoint<R>) async throws -> R {
        requestedPaths.append(endpoint.path)
        guard let result = responses[endpoint.path] else {
            Issue.record("No stubbed response for \(endpoint.path)")
            throw URLError(.badURL)
        }
        return try result.get() as! R
    }
}

@MainActor
final class InMemoryTokenStore: TokenStore {
    private(set) var token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func save(_ token: String) { self.token = token }
    func clear() { token = nil }
}

extension AuthSession {
    static let stub = AuthSession(
        user: User(id: "1", name: "Test", email: "a@b.com", phone: nil, avatarURL: nil, city: nil),
        role: .customer
    )
}

/// Builds a JWT whose payload `JWTClaims` can decode. Header and signature are dummies.
func makeJWT(role: String) -> String {
    let payload = #"{"id":"1","email":"a@b.com","role":"\#(role)"}"#
    let base64URL = Data(payload.utf8).base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    return "header.\(base64URL).signature"
}
