//
//  Coordinate.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

nonisolated struct Coordinate: Hashable, Sendable, CustomStringConvertible {
    var description: String { "(\(latitude), \(longitude))" }

    let latitude: Double
    let longitude: Double
}

nonisolated extension Coordinate {
    /// 两点之间的直线距离（公里），使用 Haversine 公式
    func distanceKm(to other: Coordinate) -> Double {
        let earthRadiusKm = 6371.0

        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let dLat = (other.latitude - latitude) * .pi / 180
        let dLon = (other.longitude - longitude) * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2)
              + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusKm * c
    }
}
