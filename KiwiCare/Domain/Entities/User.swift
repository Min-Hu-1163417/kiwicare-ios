//
//  User.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import Foundation

struct User: Equatable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let avatarURL: URL?
    let city: String?
}
