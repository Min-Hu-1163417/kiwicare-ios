//
//  Provider.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

nonisolated struct Provider: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let avatarURL: URL?
    let address: String
    let coordinate: Coordinate
    let bio: String?
    let serviceRadiusKm: Double
}
