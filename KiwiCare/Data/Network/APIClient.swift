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
        if endpoint.method == .get {
            return try await withRetry(shouldRetry: { error in
                (error as? APIError)?.isRetryable ?? false
            }) {
                try await performRequest(endpoint)
            }
        }
        return try await performRequest(endpoint)
    }
    
    func performRequest<R: Decodable>(_ endpoint: Endpoint<R>) async throws -> R {
        var request = makeRequest(for: endpoint)
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await perform { try await session.data(for: request) }
        return try decode(R.self, data: data, response: response)
    }

    func upload<R: Decodable>(
        _ endpoint: Endpoint<R>,
        file: MultipartFile,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws -> R {
        var request = makeRequest(for: endpoint)
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = MultipartFormData.body(for: file, boundary: boundary)
        let delegate = UploadProgressDelegate(onProgress: onProgress)

        let (data, response) = try await perform {
            try await session.upload(for: request, from: body, delegate: delegate)
        }
        return try decode(R.self, data: data, response: response)
    }

    // MARK: - Private

    private func makeRequest<R>(for endpoint: Endpoint<R>) -> URLRequest {
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
        return request
    }

    /// 网络层的错误（断网、超时、取消）统一包装成 APIError.network
    private func perform(
        _ operation: () async throws -> (Data, URLResponse)
    ) async throws -> (Data, URLResponse) {
        do {
            return try await operation()
        } catch {
            throw APIError.network(error)
        }
    }

    /// 检查状态码、处理 401、解开最外层的 { data, code }
    private func decode<R: Decodable>(_ type: R.Type, data: Data, response: URLResponse) throws -> R {
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
