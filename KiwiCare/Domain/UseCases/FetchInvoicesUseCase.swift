//
//  FetchInvoicesUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

protocol FetchInvoicesUseCase {
    func execute(userID: String) throws -> [Invoice]

    /// 发票有变化时发出事件，列表收到后重新加载
    func changes() -> AsyncStream<Void>
}

struct DefaultFetchInvoicesUseCase: FetchInvoicesUseCase {
    let repository: InvoiceRepository
    
    func execute(userID: String) throws -> [Invoice] {
        try repository.invoices(for: userID)
    }

    func changes() -> AsyncStream<Void> {
        repository.changes()
    }
}
