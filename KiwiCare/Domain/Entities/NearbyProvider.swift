//
//  NearbyProvider.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

nonisolated struct NearbyProvider: Identifiable, Hashable, Sendable {
    let provider: Provider
    let distanceKm: Double
    
    var id: UUID {
        provider.id
    }
}
