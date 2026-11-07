//
//  InvoiceSyncCoordinator.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

final class InvoiceSyncCoordinator {
    var onSyncFinished: () -> Void = {}
    
    private let syncInvoices: SyncInvoiceUseCase
    private let networkMonitor: NetworkMonitor
    
    init(syncInvoices: SyncInvoiceUseCase, networkMonitor: NetworkMonitor) {
        self.syncInvoices = syncInvoices
        self.networkMonitor = networkMonitor
    }
    
    func start() {
        networkMonitor.onConnected = { [weak self] in
            self?.requestSync()
        }
        networkMonitor.start()
    }
    
    func requestSync() {
        Task {
            await syncInvoices.execute()
            onSyncFinished()
        }
    }
}
