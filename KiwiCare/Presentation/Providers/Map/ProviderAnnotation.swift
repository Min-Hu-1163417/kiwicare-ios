//
//  ProviderAnnotation.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import MapKit

final class ProviderAnnotation: NSObject, MKAnnotation {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(_ item: NearbyProvider) {
        id = item.id
        coordinate = CLLocationCoordinate2D(
            latitude: item.provider.coordinate.latitude,
            longitude: item.provider.coordinate.longitude
        )
        title = item.provider.name
        subtitle = item.provider.address
    }
}
