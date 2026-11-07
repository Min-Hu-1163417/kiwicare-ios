//
//  RootView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import SwiftUI

struct RootView: View {
    let container: AppContainer

    var body: some View {
        switch container.session.state {
        case .loading:
            ProgressView()
        case .signedOut:
            NavigationStack {
                LoginView(viewModel: container.makeLoginViewModel())
            }
        case .signedIn(let authSession):
            NavigationStack {
                HomeView(session: authSession, onSignOut: container.session.signOut)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Connection failed", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") {
                    Task { await container.session.restore() }
                }
            }
        }
    }
}
