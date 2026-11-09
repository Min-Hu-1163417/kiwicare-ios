//
//  DefaultProviderRepository.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

struct DefaultProviderRepository: ProviderRepository {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func nearbyProviders(
        around coordinate: Coordinate,
        radiusKm: Double,
        page: Int,
        pageSize: Int,
        keyword: String?
    ) async throws -> ProviderPage {
        do {
            let response: ProviderListResponse = try await client.send(
                .nearbyProviders(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    radiusKm: radiusKm,
                    page: page,
                    limit: pageSize,
                    keyword: keyword
                )
            )
            return ProviderPage(
                providers: response.data.compactMap { $0.toDomain() },
                total: response.total
            )
        } catch {
            throw mapError(error)
        }
    }
    
    func provider(id: UUID) async throws -> Provider {
        let dto: ProviderDTO?
        do {
            dto = try await client.send(.provider(id: id))
        } catch {
            throw mapError(error)
        }
        
        guard let provider = dto?.toDomain() else {
            throw ProviderError.notFound
        }
        return provider
    }
    
    private func mapError(_ error: Error) -> ProviderError {
        switch error as? APIError {
        case .network: .network
        case .unauthorized: .sessionExpired
        default: .unknown
        }
    }
}
