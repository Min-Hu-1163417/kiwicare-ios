//
//  EmailValidator.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

enum EmailValidator {
    static func isValid(_ email: String) -> Bool {
        email.wholeMatch(of: /[^\s@]+@[^\s@]+\.[^\s@]+/) != nil
    }
}
