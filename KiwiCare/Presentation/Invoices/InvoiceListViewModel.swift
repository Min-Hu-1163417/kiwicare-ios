//
//  InvoiceListViewModel.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Observation

@Observable
final class InvoiceListViewModel {
    private(set) var invoices: [Invoice] = []
    private(set) var errorMessage: String?
    
    private let useCase: FetchInvoicesUseCase
    private let userID: String
    
    init(useCase: FetchInvoicesUseCase, userID: String) {
        self.useCase = useCase
        self.userID = userID
    }
    
    func load() {
        do {
            invoices = try useCase.execute(userID: userID)
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't load invoices."
        }
    }
}
