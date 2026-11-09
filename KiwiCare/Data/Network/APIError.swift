//
//  APIError.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import Foundation

enum APIError: LocalizedError {
    case network(Error)
    case unauthorized(String)
    case server(status: Int, message: String)
    case decoding(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .network: "网络连接失败"
        case .unauthorized(let msg): msg
        case .server(_, let msg): msg
        case .decoding(let error): "数据解析失败：\(error)"
        case .invalidResponse: "无效的响应"
        }
    }
}

extension APIError {
    /// 这个错误值不值得重试
    var isRetryable: Bool {
        switch self {
        case .network(let error):
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return false
            }
            return true

        case .server(let status, _):
            return (500..<600).contains(status)

        case .unauthorized, .decoding, .invalidResponse:
            return false
        }
    }
}
