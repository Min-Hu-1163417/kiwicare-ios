//
//  Endpoint.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET", post = "POST", patch = "PATCH"
}

struct Endpoint<Response: Decodable> {
    var path: String
    var method: HTTPMethod = .get
    var query: [URLQueryItem] = []
    var body: (any Encodable)? = nil
}
