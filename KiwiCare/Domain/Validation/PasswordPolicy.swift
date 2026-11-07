//
//  PasswordPolicy.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

enum PasswordPolicy {
    static let minLength = 8

    static func isValid(_ password: String) -> Bool {
        password.count >= minLength
            && password.contains(where: \.isUppercase)
            && password.contains(where: \.isLowercase)
            && password.contains(where: \.isNumber)
            && password.contains(where: { !$0.isLetter && !$0.isNumber && !$0.isWhitespace })
    }
}
