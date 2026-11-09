//
//  InvoiceListViewModel.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation
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
            errorMessage = String(localized: "Couldn't load invoices.")
        }
    }
    
    /// 一直监听发票的变化，有变化就重新加载，直到任务被取消（页面消失）
    func observeChanges() async {
        for await _ in useCase.changes() {
            load()
        }
    }
}
