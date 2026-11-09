//
//  FetchInvoiceStatsUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

protocol FetchInvoiceStatsUseCase: Sendable {
    func execute(userID: String) async throws -> InvoiceStats
}

final class DefaultFetchInvoiceStatsUseCase : FetchInvoiceStatsUseCase {
    let repository: InvoiceRepository
    
    init(repository: InvoiceRepository) {
        self.repository = repository
    }
    
    func execute(userID: String) async throws -> InvoiceStats {
        let invoices = try repository.invoices(for: userID)
        return InvoiceStats(count: invoices.count, totalAmount: invoices.reduce(0) { $0 + $1.amount }, pendingCount: invoices.filter { $0.syncStatus != .synced }.count )
    }
}
