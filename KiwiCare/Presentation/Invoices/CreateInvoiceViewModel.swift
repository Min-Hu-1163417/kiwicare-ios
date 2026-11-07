//
//  CreateInvoiceViewModel.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation
import Observation

@Observable
final class CreateInvoiceViewModel {
    var amountText = ""
    var paymentMethod: PaymentMethod = .cash
    var note = ""
    private(set) var errorMessage: String?
    
    var canSave: Bool {
        amountInCents != nil
    }
    
    private let createInvoice: CreateInvoiceUseCase
    private let onCreated: (Invoice) -> Void
    
    init(createInvoice: CreateInvoiceUseCase, onCreated: @escaping (Invoice) -> Void) {
        self.createInvoice = createInvoice
        self.onCreated = onCreated
    }
    
    func save() -> Bool {
        guard let amount = amountInCents else {
            errorMessage = Self.message(for: .invalidAmount)
            return false
        }
        
        do {
            let invoice = try createInvoice.execute(amount: amount, paymentMethod: paymentMethod, description: note)
            onCreated(invoice)
            return true
        } catch let error as InvoiceError {
            errorMessage = Self.message(for: error)
            return false
        } catch {
            errorMessage = Self.message(for: .storageFailed)
            return false
        }
    }
    
    private var amountInCents: Int? {
        guard let value = Decimal(string: amountText, locale: .current), value > 0 else {
            return nil
        }
        var cents = value * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &cents, 0, .plain)
        return NSDecimalNumber(decimal: rounded).intValue
    }
    
    private static func message(for error: InvoiceError) -> String {
        switch error {
        case .invalidAmount: "Please enter an amount greater than 0."
        case .notSignedIn: "You need to sign in again."
        case .storageFailed: "Couldn't save the invoice. Please try again."
        }
    }
}
