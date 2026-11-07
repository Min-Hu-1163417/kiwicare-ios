//
//  DefaultAuthRepository.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

final class DefaultAuthRepository: AuthRepository {
    private let client: HTTPClient
    private let tokenStore: TokenStore
    
    init(client: HTTPClient, tokenStore: TokenStore) {
        self.client = client
        self.tokenStore = tokenStore
    }
    
    func signIn(email: String, password: String) async throws -> AuthSession {
        do {
            let token = try await client.send(.login(email: email, password: password)).token
            tokenStore.save(token)
            return try await loadSession(token: token)
        } catch {
            tokenStore.clear()
            throw Self.mapSignInError(error)
        }
    }
    
    func restoreSession() async throws -> AuthSession? {
        guard let token = tokenStore.token else { return nil }
        do {
            return try await loadSession(token: token)
        } catch {
            let authError = Self.mapRestoreError(error)
            if authError == .sessionExpired {
                tokenStore.clear()
            }
            throw authError
        }
    }
    
    func signOut() {
        tokenStore.clear()
    }
    
    // MARK: - Private
    
    private func loadSession(token: String) async throws -> AuthSession {
        guard let role = JWTClaims(token: token)?.role else {
            throw AuthError.sessionExpired
        }
        let dto = try await client.send(.me)
        return AuthSession(user: dto.toDomain(), role: role)
    }
    
    private static func mapSignInError(_ error: Error) -> AuthError {
        switch error {
        case let error as AuthError: error
        case APIError.network: .network
        case APIError.unauthorized: .invalidCredentials
        case APIError.server(let status, _) where (400..<500).contains(status): .invalidCredentials
        default: .unknown
        }
    }
    
    private static func mapRestoreError(_ error: Error) -> AuthError {
        switch error {
        case let error as AuthError: error
        case APIError.network: .network
        case APIError.unauthorized: .sessionExpired
        default: .unknown
        }
    }
}
