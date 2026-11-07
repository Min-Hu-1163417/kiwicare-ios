//
//  KiwiCareApp.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import SwiftUI

@main
struct KiwiCareApp: App {
    @State private var container = AppContainer()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .task { await container.session.restore() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                container.invoiceSync.requestSync()
            }
        }
    }
}
