//
//  AppConfig.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import Foundation

enum AppConfig {
    #if DEBUG
    static let baseURL = URL(string: "http://192.168.88.4:9080/api")!
    #else
    static let baseURL = URL(string: "https://your-production-host/api")!
    #endif
}
