//
//  ProviderDTO.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

nonisolated struct ProviderDTO: Decodable {
    let id: UUID
    let serviceRadiusKm: Int
    let baseAddress: String?
    let baseLatitude: Double?
    let baseLongitude: Double?
    let bio: String?
    let user: ProviderUserDTO
}

nonisolated struct ProviderUserDTO: Decodable {
    let name: String
    let avatar: String?
}

/// 附近服务商接口里面那一层：{ "data": [...], "total": 3 }
nonisolated struct ProviderListResponse: Decodable {
    let data: [ProviderDTO]
    let total: Int
}

nonisolated extension ProviderDTO {
    /// 没有坐标的服务商无法计算距离，返回 nil
    func toDomain() -> Provider? {
        guard let baseLatitude, let baseLongitude else { return nil }
        
        return Provider(
            id: id,
            name: user.name,
            avatarURL: user.avatar.flatMap(URL.init(string:)),
            address: baseAddress ?? "",
            coordinate: Coordinate(latitude: baseLatitude, longitude: baseLongitude),
            bio: bio,
            serviceRadiusKm: Double(serviceRadiusKm)
        )
    }
}
