//
//  CoreLocationProvider.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import CoreLocation

final class CoreLocationProvider: LocationProvider {
    private let timeout: Duration
    
    init(timeout: Duration = .seconds(15)) {
        self.timeout = timeout
    }
    
    func currentLocation() async throws -> Coordinate {
        try await withThrowingTaskGroup(of: Coordinate.self) { group in
            group.addTask { try await self.firstLocation() }
            group.addTask { [timeout] in
                try await Task.sleep(for: timeout)
                throw LocationError.unavailable
            }
            defer { group.cancelAll() }
            
            guard let coordinate = try await group.next() else {
                throw LocationError.unavailable
            }
            return coordinate
        }
    }
    
    private func firstLocation() async throws -> Coordinate {
        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }
        
        for try await update in CLLocationUpdate.liveUpdates() {
            if update.authorizationDenied || update.authorizationDeniedGlobally {
                throw LocationError.denied
            }
            if let location = update.location {
                return Coordinate(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            if update.locationUnavailable {
                throw LocationError.unavailable
            }
        }
        throw LocationError.unavailable
    }
}
