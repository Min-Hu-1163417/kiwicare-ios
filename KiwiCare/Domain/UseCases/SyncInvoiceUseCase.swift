//
//  SyncInvoiceUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

protocol SyncInvoiceUseCase {
    func execute() async
}

struct DefaultSyncInvoicesUseCase: SyncInvoiceUseCase {
    let repository: InvoiceRepository
    
    func execute() async {
        await repository.syncPending()
    }
}
