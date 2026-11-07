//
//  UserEndpoints.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

extension Endpoint where Response == UserDTO {
    static var me: Self { .init(path: "user") }
}
