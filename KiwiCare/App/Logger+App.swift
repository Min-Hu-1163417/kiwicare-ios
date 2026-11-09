//
//  Logger+App.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import OSLog

nonisolated extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "KiwiCare"

    static let network = Logger(subsystem: subsystem, category: "Network")
    static let providers = Logger(subsystem: subsystem, category: "Providers")
    static let sync = Logger(subsystem: subsystem, category: "Sync")
}
