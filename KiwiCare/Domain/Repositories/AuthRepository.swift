//
//  AuthRepository.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

protocol AuthRepository {
    func signIn(email: String, password: String) async throws -> AuthSession
    func restoreSession() async throws -> AuthSession?
    func signOut()
}
