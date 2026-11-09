//
//  HTTPClient.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

protocol HTTPClient {
    func send<R: Decodable>(_ endpoint: Endpoint<R>) async throws -> R
    func upload<R: Decodable>(
        _ endpoint: Endpoint<R>,
        file: MultipartFile,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws -> R
}

extension APIClient: HTTPClient {}
