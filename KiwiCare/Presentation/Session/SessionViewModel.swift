//
//  SessionViewModel.swift
//  KiwiCare
//

import Observation

/// App-wide authentication state. Drives which root screen is shown.
@Observable
final class SessionViewModel {
    enum State {
        case loading
        case signedOut
        case signedIn(AuthSession)
        case failed(String)
    }

    private(set) var state: State = .loading
    private let restoreSessionUseCase: RestoreSessionUseCase
    private let signOutUseCase: SignOutUseCase

    init(restoreSession: RestoreSessionUseCase, signOut: SignOutUseCase) {
        self.restoreSessionUseCase = restoreSession
        self.signOutUseCase = signOut
    }

    func restore() async {
        state = .loading
        do {
            if let session = try await restoreSessionUseCase.execute() {
                state = .signedIn(session)
            } else {
                state = .signedOut
            }
        } catch AuthError.sessionExpired {
            state = .signedOut
        } catch AuthError.network {
            state = .failed("Unable to connect. Please check your network.")
        } catch {
            state = .failed("Something went wrong. Please try again.")
        }
    }

    func didSignIn(_ session: AuthSession) {
        state = .signedIn(session)
    }

    func signOut() {
        signOutUseCase.execute()
        state = .signedOut
    }
}
