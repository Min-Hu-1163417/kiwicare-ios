//
//  Retry.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import OSLog

struct  RrtryPolicy: Sendable {
    var maxRetries = 3
    var initialDelay: Duration = .seconds(1)
    
    static let `default` = RrtryPolicy()
}

func withRetry<T>(
    policy: RrtryPolicy = .default,
    shouldRetry: (Error) -> Bool,
    operation: () async throws -> T) async throws -> T {
        var delay = policy.initialDelay
        
        for attempt in 1...policy.maxRetries {
            do {
                return try await operation()
            } catch {
                // 被取消了，或者这个错误不值得重试：直接抛出去
                guard !Task.isCancelled, shouldRetry(error) else { throw error }
                
                Logger.network.info("Attempt \(attempt) failed, retrying in \(delay)")
                try await Task.sleep(for: delay)   // 等待期间被取消，会抛出错误，不再重试
                delay *= 2
            }
        }
        
        return try await operation()
    }

