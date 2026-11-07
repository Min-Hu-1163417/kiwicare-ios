//
//  NetworkMonitor.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Network

final class NetworkMonitor {
    var onConnected: () -> Void = {}
    private(set) var isConnected = false
    private var task: Task<Void, Never>?
    
    func start() {
        guard task == nil else { return }
        task = Task {
            for await path in NWPathMonitor() {
                let connected = path.status == .satisfied
                if connected && !isConnected {
                    onConnected()
                }
                isConnected = connected
            }
        }
    }
    
    func stop() {
        task?.cancel()
        task = nil
    }
}
