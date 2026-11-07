//
//  HTTPClient.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

protocol HTTPClient {
    func send<R: Decodable>(_ endpoint: Endpoint<R>) async throws -> R
}

extension APIClient: HTTPClient {}
