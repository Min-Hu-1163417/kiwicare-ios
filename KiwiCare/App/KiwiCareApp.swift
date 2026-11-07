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

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .task { await container.session.restore() }
        }
    }
}
