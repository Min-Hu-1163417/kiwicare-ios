//
//  SessionViewModelTests.swift
//  KiwiCareTests
//

import Testing
@testable import KiwiCare

@MainActor
struct SessionViewModelTests {
    private func makeViewModel(
        restore: MockRestoreSessionUseCase = MockRestoreSessionUseCase(),
        signOut: MockSignOutUseCase = MockSignOutUseCase()
    ) -> SessionViewModel {
        SessionViewModel(restoreSession: restore, signOut: signOut)
    }

    @Test func restoreWithSessionSignsIn() async {
        let restore = MockRestoreSessionUseCase()
        restore.result = .success(.stub)
        let vm = makeViewModel(restore: restore)

        await vm.restore()

        guard case .signedIn(let session) = vm.state else {
            Issue.record("Expected signedIn, got \(vm.state)")
            return
        }
        #expect(session == AuthSession.stub)
    }

    @Test func restoreWithoutSessionSignsOut() async {
        let vm = makeViewModel()

        await vm.restore()

        guard case .signedOut = vm.state else {
            Issue.record("Expected signedOut, got \(vm.state)")
            return
        }
    }

    @Test func restoreExpiredSessionSignsOut() async {
        let restore = MockRestoreSessionUseCase()
        restore.result = .failure(AuthError.sessionExpired)
        let vm = makeViewModel(restore: restore)

        await vm.restore()

        guard case .signedOut = vm.state else {
            Issue.record("Expected signedOut, got \(vm.state)")
            return
        }
    }

    @Test func restoreNetworkErrorShowsFailure() async {
        let restore = MockRestoreSessionUseCase()
        restore.result = .failure(AuthError.network)
        let vm = makeViewModel(restore: restore)

        await vm.restore()

        guard case .failed = vm.state else {
            Issue.record("Expected failed, got \(vm.state)")
            return
        }
    }

    @Test func signOutCallsUseCaseAndSignsOut() {
        let signOut = MockSignOutUseCase()
        let vm = makeViewModel(signOut: signOut)
        vm.didSignIn(.stub)

        vm.signOut()

        #expect(signOut.callCount == 1)
        guard case .signedOut = vm.state else {
            Issue.record("Expected signedOut, got \(vm.state)")
            return
        }
    }
}
