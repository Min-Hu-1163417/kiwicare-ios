//
//  SignInUseCaseTests.swift
//  KiwiCareTests
//

import Testing
@testable import KiwiCare

@MainActor
struct SignInUseCaseTests {
    @Test func invalidEmailDoesNotCallRepository() async {
        let repo = MockAuthRepository()
        let useCase = DefaultSignInUseCase(repository: repo)

        await #expect(throws: AuthError.invalidEmail) {
            try await useCase.execute(email: "not-an-email", password: "Pass@1234")
        }
        #expect(repo.signInCalls.isEmpty)
    }

    @Test func weakPasswordDoesNotCallRepository() async {
        let repo = MockAuthRepository()
        let useCase = DefaultSignInUseCase(repository: repo)

        await #expect(throws: AuthError.invalidPassword) {
            try await useCase.execute(email: "a@b.com", password: "password")
        }
        #expect(repo.signInCalls.isEmpty)
    }

    @Test func emailIsTrimmedAndLowercased() async throws {
        let repo = MockAuthRepository()
        let useCase = DefaultSignInUseCase(repository: repo)

        _ = try await useCase.execute(email: "  A@B.com ", password: "Pass@1234")

        #expect(repo.signInCalls.first?.email == "a@b.com")
        #expect(repo.signInCalls.first?.password == "Pass@1234")
    }

    @Test func returnsRepositorySession() async throws {
        let repo = MockAuthRepository()
        let useCase = DefaultSignInUseCase(repository: repo)

        let session = try await useCase.execute(email: "a@b.com", password: "Pass@1234")

        #expect(session == AuthSession.stub)
    }

    @Test func propagatesRepositoryError() async {
        let repo = MockAuthRepository()
        repo.signInResult = .failure(AuthError.invalidCredentials)
        let useCase = DefaultSignInUseCase(repository: repo)

        await #expect(throws: AuthError.invalidCredentials) {
            try await useCase.execute(email: "a@b.com", password: "Pass@1234")
        }
    }
}
