//
//  NearbyProviderRow.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import SwiftUI

struct NearbyProviderRow: View {
    let item: NearbyProvider
    
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(url: item.provider.avatarURL)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.provider.name)
                    .font(.headline)
                Text(item.provider.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(distanceText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
    
    private var distanceText: String {
        Measurement(value: item.distanceKm, unit: UnitLength.kilometers)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }
}
