//
//  ProviderError.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

nonisolated enum ProviderError: Error, Equatable {
    case network
    case notFound
    case sessionExpired
    case unknown
}
