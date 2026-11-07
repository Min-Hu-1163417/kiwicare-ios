//
//  ProfileView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import SwiftUI

struct ProfileView: View {
    let session: AuthSession
    let onSignOut: () -> Void
    
    var body: some View {
        List {
            LabeledContent("Name", value: session.user.name)
            LabeledContent("Email", value: session.user.email)
            LabeledContent("Role", value: session.role.rawValue)
            Button("Sign out", role: .destructive, action: onSignOut)
        }
        .navigationTitle("Profile")
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        ProfileView(
            session: AuthSession.preview,
            onSignOut: {}
        )
    }
}

#endif
