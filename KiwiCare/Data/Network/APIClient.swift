//
//  APIClient.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import Foundation

private struct Envelope<T: Decodable>: Decodable {
    let code: Int
    let data: T
}

private struct ErrorBody: Decodable {
    let message: String
}

final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder = JSONEncoder()
    var tokenProvider: () -> String? = { nil }
    var onUnauthorized: () -> Void = {}
    
    init(baseURL: URL = AppConfig.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            if let date = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(string) {
                return date
            }
            return try Date.ISO8601FormatStyle().parse(string)
        }
        self.decoder = decoder
    }
    
    func send<R: Decodable>(_ endpoint: Endpoint<R>) async throws -> R {
        var components = URLComponents(url: baseURL.appending(path: endpoint.path), resolvingAgainstBaseURL: false)!
        
        if !endpoint.query.isEmpty {
            components.queryItems = endpoint.query
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? decoder.decode(ErrorBody.self, from: data))?.message
                            ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            if http.statusCode == 401 {
                if tokenProvider() != nil {
                    onUnauthorized()
                }
                throw APIError.unauthorized(message)
            }
            throw APIError.server(status: http.statusCode, message: message)
        }
        
        do {
            return try decoder.decode(Envelope<R>.self, from: data).data
        } catch {
            throw APIError.decoding(error)
        }
    }
}
