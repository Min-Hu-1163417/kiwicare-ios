//
//  ProvidersMapView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import MapKit
import SwiftUI

struct ProvidersMapView: UIViewRepresentable {
    let providers: [NearbyProvider]
    @Binding var selectedID: UUID?    // 这一步先不用，下一步用

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        let existing = map.annotations.compactMap { $0 as? ProviderAnnotation }
        let existingIDs = Set(existing.map(\.id))
        let currentIDs = Set(providers.map(\.id))

        let toRemove = existing.filter { !currentIDs.contains($0.id) }
        let toAdd = providers
            .filter { !existingIDs.contains($0.id) }
            .map(ProviderAnnotation.init)

        map.removeAnnotations(toRemove)
        map.addAnnotations(toAdd)

        // 第一次有数据时，缩放到能看到所有服务商
        if existing.isEmpty, !toAdd.isEmpty {
            map.showAnnotations(toAdd, animated: false)
        }
    }
}
