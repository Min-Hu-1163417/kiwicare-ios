//
//  AppContainer.swift
//  KiwiCare
//

/// Composition root: the only place that creates concrete implementations
/// and wires them together.
final class AppContainer {
    let session: SessionViewModel
    private let signInUseCase: SignInUseCase

    init() {
        // Data
        let tokenStore = KeychainTokenStore()
        let client = APIClient()
        client.tokenProvider = { [tokenStore] in tokenStore.token }
        let authRepository = DefaultAuthRepository(client: client, tokenStore: tokenStore)

        // Domain
        let signIn = DefaultSignInUseCase(repository: authRepository)
        let restoreSession = DefaultRestoreSessionUseCase(repository: authRepository)
        let signOut = DefaultSignOutUseCase(repository: authRepository)

        // Presentation
        let session = SessionViewModel(restoreSession: restoreSession, signOut: signOut)
        // weak: session -> use case -> repository -> client -> this closure would otherwise form a cycle
        client.onUnauthorized = { [weak session] in session?.signOut()
        }

        self.session = session
        self.signInUseCase = signIn
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(signIn: signInUseCase) { [session] authSession in
            session.didSignIn(authSession)
        }
    }
}
