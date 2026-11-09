//
//  ProviderHeaderView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import SwiftUI

struct ProviderHeaderView: View {
    let item: NearbyProvider
    var onCreateInvoice: () -> Void = {}

    var body: some View {
        VStack(spacing: 8) {
            AvatarView(url: item.provider.avatarURL, size: 88)
            Text(distanceText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Create invoice", systemImage: "doc.badge.plus", action: onCreateInvoice)
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    private var distanceText: String {
        Measurement(value: item.distanceKm, unit: UnitLength.kilometers)
                    .formatted(.measurement(width: .abbreviated, usage: .road))
    }
}

#if DEBUG

#Preview {
    ProviderHeaderView(item: NearbyProvider.previewSamples[0]) {
        
    }
}

#endif
