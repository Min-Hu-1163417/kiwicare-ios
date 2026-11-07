//
//  SignOutUseCase.swift
//  KiwiCare
//

protocol SignOutUseCase {
    func execute()
}

struct DefaultSignOutUseCase: SignOutUseCase {
    let repository: AuthRepository

    func execute() {
        repository.signOut()
    }
}
