//
//  LocationSource.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

nonisolated enum LocationSource: Equatable, Sendable {
    case current                  // 用户的真实位置
    case fallback(LocationError)  // 默认位置，附带原因
}

nonisolated struct NearbyProvidersPage: Equatable, Sendable {
    let providers: [NearbyProvider]
    let page: Int
    let hasMore: Bool
    let location: Coordinate          // 这一页用的位置，翻页时要用同一个
    let locationSource: LocationSource
    let keyword: String?
}

nonisolated struct ProviderPage: Equatable, Sendable {
    let providers: [Provider]
    let total: Int
}
