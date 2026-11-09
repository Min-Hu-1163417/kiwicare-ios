//
//  ProviderRepository.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

protocol ProviderRepository {
    func nearbyProviders(
            around coordinate: Coordinate,
            radiusKm: Double,
            page: Int,
            pageSize: Int,
            keyword: String?
        ) async throws -> ProviderPage
    func provider(id: UUID) async throws -> Provider
}
