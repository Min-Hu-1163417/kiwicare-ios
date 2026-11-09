//
//  LocationProvider.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

protocol LocationProvider {
    func currentLocation() async throws -> Coordinate
}
