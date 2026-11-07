//
//  CreateInoiceUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation

protocol CreateInvoiceUseCase {
    func execute(amount: Int, paymentMethod: PaymentMethod, description: String?) throws -> Invoice
}

struct DefaultCreateInvoiceUseCase: CreateInvoiceUseCase {
    let repo: InvoiceRepository
    let currentUserID: () -> String?
    
    
    func execute(amount: Int, paymentMethod: PaymentMethod, description: String?) throws -> Invoice {
        guard let userID = currentUserID() else {
            throw InvoiceError.notSignedIn
        }
        
        guard amount > 0 else {
            throw InvoiceError.invalidAmount
        }
        
        let trimmed = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let invoice = Invoice(id: UUID(), userID: userID, amount: amount, paymentMethod: paymentMethod, description: trimmed, createdAt: .now, syncStatus: .pending)
        
        try repo.save(invoice)
        
        return invoice
    }
}
