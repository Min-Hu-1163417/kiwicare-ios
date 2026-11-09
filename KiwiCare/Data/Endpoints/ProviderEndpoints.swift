//
//  ProviderEndpoints.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

extension Endpoint where Response == ProviderListResponse {
    static func nearbyProviders(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        page: Int,
        limit: Int,
        keyword: String?
    ) -> Self {
        var query = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "radius", value: String(radiusKm)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
        
        if let keyword, !keyword.isEmpty {
            query.append(contentsOf: [URLQueryItem(name: "keyword", value: keyword)])
        }
        
        return .init(path: "provider/nearby", query: query)
    }
}

extension Endpoint where Response == ProviderDTO? {
    static func provider(id: UUID) -> Self {
        .init(path: "provider/\(id.uuidString.lowercased())")
    }
}
