//
//  AvatarView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import SwiftUI
import Kingfisher

struct AvatarView: View {
    let url: URL?
    var size: CGFloat = 44
    
    @Environment(\.displayScale) private var displayScale
    
    var body: some View {
        Group {
            if let url {
                KFImage(url)
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size, height: size)))
                    .scaleFactor(displayScale)
                    .cacheOriginalImage()
                    .fade(duration: 0.2)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var placeholder: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .foregroundStyle(.secondary)
    }
}
