//
//  UserDTO.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import Foundation

struct UserDTO: Decodable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let avatar: String?
    let city: String?
    let status: String
    let emailVerified: Bool
}

extension UserDTO {
    func toDomain() -> User {
        User(
            id: id,
            name: name,
            email: email,
            phone: phone,
            avatarURL: avatar.flatMap(URL.init(string:)),
            city: city
        )
    }
}
