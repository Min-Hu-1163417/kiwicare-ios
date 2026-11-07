//
//  JWTClaims.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import Foundation

struct JWTClaims: Decodable {
    let id: String
    let email: String
    private let roleValue: String
    var role: Role? {
        Role(rawValue: roleValue)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case roleValue = "role"
    }
    
    init?(token: String) {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }

        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)

        guard let data = Data(base64Encoded: base64),
              let claims = try? JSONDecoder().decode(JWTClaims.self, from: data) else { return nil }
        self = claims
    }
}
