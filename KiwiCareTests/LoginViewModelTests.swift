//
//  LoginViewModelTests.swift
//  KiwiCareTests
//

import Testing
@testable import KiwiCare

@MainActor
struct LoginViewModelTests {
    private func makeViewModel(
        signIn: MockSignInUseCase = MockSignInUseCase(),
        onSignedIn: @escaping (AuthSession) -> Void = { _ in }
    ) -> LoginViewModel {
        let vm = LoginViewModel(signIn: signIn, onSignedIn: onSignedIn)
        vm.email = "a@b.com"
        vm.password = "Pass@1234"
        return vm
    }

    @Test func cannotSubmitWithEmptyFields() {
        let vm = makeViewModel()
        vm.email = ""
        vm.password = ""
        #expect(vm.canSubmit == false)
    }

    @Test func successPassesInputAndNotifiesSignedIn() async {
        let signIn = MockSignInUseCase()
        var received: AuthSession?
        let vm = makeViewModel(signIn: signIn) { received = $0 }

        await vm.submit()

        #expect(signIn.calls.count == 1)
        #expect(signIn.calls.first?.email == "a@b.com")
        #expect(received == AuthSession.stub)
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }

    @Test(arguments: [
        (AuthError.invalidEmail, "Please enter a valid email address."),
        (AuthError.invalidCredentials, "Incorrect email or password."),
        (AuthError.network, "Unable to connect. Please check your network."),
        (AuthError.unknown, "Something went wrong. Please try again."),
    ])
    func errorShowsMessage(_ error: AuthError, _ message: String) async {
        let signIn = MockSignInUseCase()
        signIn.result = .failure(error)
        let vm = makeViewModel(signIn: signIn)

        await vm.submit()

        #expect(vm.errorMessage == message)
        #expect(vm.isLoading == false)
    }

    @Test func doubleSubmitSendsOneRequest() async {
        let signIn = MockSignInUseCase()
        signIn.delay = .milliseconds(50)
        let vm = makeViewModel(signIn: signIn)

        async let first: Void = vm.submit()
        async let second: Void = vm.submit()
        _ = await (first, second)

        #expect(signIn.calls.count == 1)
    }
}
