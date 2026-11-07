//
//  AuthEndpoints.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

extension Endpoint where Response == TokenResponse {
    static func login(email: String, password: String) -> Self {
        .init(path: "auth/login", method: .post, body: LoginRequest(email: email, password: password))
    }
}
