//
//  AuthError.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

enum AuthError: Error, Equatable {
    case invalidEmail
    case invalidPassword
    case invalidCredentials
    case sessionExpired
    case network
    case unknown
}
