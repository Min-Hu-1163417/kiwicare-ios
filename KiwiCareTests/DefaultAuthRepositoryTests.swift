//
//  DefaultAuthRepositoryTests.swift
//  KiwiCareTests
//

import Testing
import Foundation
@testable import KiwiCare

@MainActor
struct DefaultAuthRepositoryTests {
    static let userDTO = UserDTO(
        id: "1", name: "Test", email: "a@b.com", phone: nil,
        avatar: "https://example.com/a.png", city: nil,
        status: "active", emailVerified: true
    )

    // MARK: - signIn

    @Test func signInSuccessSavesTokenAndReturnsSession() async throws {
        let token = makeJWT(role: "customer")
        let client = MockHTTPClient()
        client.responses["auth/login"] = .success(TokenResponse(token: token))
        client.responses["user"] = .success(Self.userDTO)
        let store = InMemoryTokenStore()
        let repo = DefaultAuthRepository(client: client, tokenStore: store)

        let session = try await repo.signIn(email: "a@b.com", password: "Pass@1234")

        #expect(store.token == token)
        #expect(session.role == .customer)
        #expect(session.user.avatarURL == URL(string: "https://example.com/a.png"))
    }

    @Test func signInWrongPasswordMapsToInvalidCredentials() async {
        let client = MockHTTPClient()
        client.responses["auth/login"] = .failure(
            APIError.server(status: 400, message: "Incorrect email or password."))
        let store = InMemoryTokenStore()
        let repo = DefaultAuthRepository(client: client, tokenStore: store)

        await #expect(throws: AuthError.invalidCredentials) {
            try await repo.signIn(email: "a@b.com", password: "Wrong@1234")
        }
        #expect(store.token == nil)
    }

    @Test func signInFailureAfterTokenSavedClearsToken() async {
        let client = MockHTTPClient()
        client.responses["auth/login"] = .success(TokenResponse(token: makeJWT(role: "customer")))
        client.responses["user"] = .failure(APIError.network(URLError(.timedOut)))
        let store = InMemoryTokenStore()
        let repo = DefaultAuthRepository(client: client, tokenStore: store)

        await #expect(throws: AuthError.network) {
            try await repo.signIn(email: "a@b.com", password: "Pass@1234")
        }
        #expect(store.token == nil)
    }

    // MARK: - restoreSession

    @Test func restoreWithoutTokenReturnsNilWithoutRequest() async throws {
        let client = MockHTTPClient()
        let repo = DefaultAuthRepository(client: client, tokenStore: InMemoryTokenStore())

        let session = try await repo.restoreSession()

        #expect(session == nil)
        #expect(client.requestedPaths.isEmpty)
    }

    @Test func restoreUnauthorizedClearsToken() async {
        let client = MockHTTPClient()
        client.responses["user"] = .failure(APIError.unauthorized("expired"))
        let store = InMemoryTokenStore(token: makeJWT(role: "customer"))
        let repo = DefaultAuthRepository(client: client, tokenStore: store)

        await #expect(throws: AuthError.sessionExpired) {
            try await repo.restoreSession()
        }
        #expect(store.token == nil)
    }

    @Test func restoreNetworkErrorKeepsToken() async {
        let token = makeJWT(role: "customer")
        let client = MockHTTPClient()
        client.responses["user"] = .failure(APIError.network(URLError(.notConnectedToInternet)))
        let store = InMemoryTokenStore(token: token)
        let repo = DefaultAuthRepository(client: client, tokenStore: store)

        await #expect(throws: AuthError.network) {
            try await repo.restoreSession()
        }
        #expect(store.token == token)
    }

    @Test func unknownRoleIsTreatedAsExpiredSession() async {
        let client = MockHTTPClient()
        let store = InMemoryTokenStore(token: makeJWT(role: "superuser"))
        let repo = DefaultAuthRepository(client: client, tokenStore: store)

        await #expect(throws: AuthError.sessionExpired) {
            try await repo.restoreSession()
        }
        #expect(client.requestedPaths.isEmpty)
    }
}
