//
//  ProvidersMap.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import SwiftUI
import MapKit

struct ProvidersMap: View {
    let providers: [NearbyProvider]
    @Binding var selectedID: UUID?
    
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position, selection: $selectedID) {
            UserAnnotation()
            
            ForEach(providers) { item in
                Annotation(
                    item.provider.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: item.provider.coordinate.latitude,
                        longitude: item.provider.coordinate.longitude
                    )
                ) {
                    let isSelected = selectedID == item.id
                    
                    AvatarView(url: item.provider.avatarURL, size: isSelected ? 52 : 40)
                        .overlay {
                            Circle().stroke(.white, lineWidth: 3)
                        }
                        .shadow(radius: 3)
                        .animation(.spring(duration: 0.25), value: isSelected)
                }
                .tag(item.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var selectedID: UUID?
    ProvidersMap(providers: NearbyProvider.previewSamples, selectedID: $selectedID)
}

#endif
