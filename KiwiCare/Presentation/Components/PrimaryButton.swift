//
//  PrimaryButton.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String = "arrow.right"
    var isLoading = false
    let action: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: systemImage)
                }
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, minHeight: Theme.controlHeight)
            .background(Color.accentColor.opacity(isEnabled ? 1 : 0.4))
            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        }
        .disabled(isLoading)
    }
}
