//
//  FetchInvoicesUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

protocol FetchInvoicesUseCase {
    func execute(userID: String) throws -> [Invoice]
}

struct DefaultFetchInvoicesUseCase: FetchInvoicesUseCase {
    let repository: DefaultInvoiceRepository
    
    func execute(userID: String) throws -> [Invoice] {
        try repository.invoices(for: userID)
    }
}
