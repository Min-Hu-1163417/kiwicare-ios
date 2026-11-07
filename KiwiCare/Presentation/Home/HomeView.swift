//
//  HomeView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import SwiftUI

struct HomeView: View {
    let session: AuthSession
    let onSignOut: () -> Void

    var body: some View {
        List {
            LabeledContent("Name", value: session.user.name)
            LabeledContent("Email", value: session.user.email)
            LabeledContent("Role", value: session.role.rawValue)
            Button("Sign out", role: .destructive, action: onSignOut)
        }
        .navigationTitle("Home")
    }
}

#Preview {
    NavigationStack {
        HomeView(
            session: AuthSession(
                user: User(id: "1", name: "Preview User", email: "preview@kiwicare.test",
                           phone: nil, avatarURL: nil, city: "Christchurch"),
                role: .customer
            ),
            onSignOut: {}
        )
    }
}
