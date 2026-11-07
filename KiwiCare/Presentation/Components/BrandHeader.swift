//
//  BrandHeader.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

import SwiftUI

struct BrandHeader: View {
    var body: some View {
        VStack {
            Image("logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
            Text("KiwiCare")
                .font(.largeTitle.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}

#Preview {
    BrandHeader()
}
