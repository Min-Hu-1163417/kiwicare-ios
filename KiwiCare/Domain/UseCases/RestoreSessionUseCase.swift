//
//  RestoreSessionUseCase.swift
//  KiwiCare
//

protocol RestoreSessionUseCase: Sendable {
    /// Returns nil when there is no stored session.
    func execute() async throws -> AuthSession?
}

struct DefaultRestoreSessionUseCase: RestoreSessionUseCase {
    let repository: AuthRepository

    func execute() async throws -> AuthSession? {
        try await repository.restoreSession()
    }
}
