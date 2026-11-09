//
//  FetchNearbyProvidersUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

protocol FetchNearbyProvidersUseCase {
    /// 获取位置，加载第一页
    func firstPage(keyword: String?) async throws -> NearbyProvidersPage
    
    /// 用第一页的位置，加载后面的页
    func page(_ page: Int, around location: Coordinate, locationSource: LocationSource, keyword: String?) async throws -> NearbyProvidersPage
}

final class DefaultFetchNearbyProvidersUseCase: FetchNearbyProvidersUseCase {
    static let defaultLocation = Coordinate(latitude: -43.5321, longitude: 172.6362) // Christchurch 市中心
    static let searchRadiusKm = 20.0
    static let pageSize = 10
    
    private let repository: ProviderRepository
    private let locationProvider: LocationProvider
    
    init(repository: ProviderRepository, locationProvider: LocationProvider) {
        self.repository = repository
        self.locationProvider = locationProvider
    }
    
    func firstPage(keyword: String?) async throws -> NearbyProvidersPage {
        let (location, source) = await resolveLocation()
        return try await page(1, around: location, locationSource: source, keyword: keyword)
    }
    
    func page(_ page: Int, around location: Coordinate, locationSource: LocationSource, keyword: String?) async throws -> NearbyProvidersPage {
        let result = try await repository.nearbyProviders(
            around: location,
            radiusKm: Self.searchRadiusKm,
            page: page,
            pageSize: Self.pageSize,
            keyword: keyword
        )
        
        // 后端已经按距离排好序了，这里只计算距离用于显示，不再排序
        let providers = result.providers.map {
            NearbyProvider(provider: $0, distanceKm: location.distanceKm(to: $0.coordinate))
        }
        
        return NearbyProvidersPage(
            providers: providers,
            page: page,
            hasMore: page * Self.pageSize < result.total,
            location: location,
            locationSource: locationSource,
            keyword: keyword
        )
    }
    
    private func resolveLocation() async -> (Coordinate, LocationSource) {
        do {
            return (try await locationProvider.currentLocation(), .current)
        } catch let error as LocationError {
            return (Self.defaultLocation, .fallback(error))
        } catch {
            return (Self.defaultLocation, .fallback(.unavailable))
        }
    }
}
