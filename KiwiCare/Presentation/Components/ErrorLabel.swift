//
//  ErrorLabel.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

import SwiftUI

struct ErrorLabel: View {
    let message: String
    
    var body: some View {
        Label(message, systemImage: "exclamationmark.circle")
            .foregroundStyle(.red)
    }
}
