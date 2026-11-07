//
//  PreviewData.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

#if DEBUG

import Foundation

extension AuthSession {
    static let preview = AuthSession(
        user: User(id: "1", name: "Preview User", email: "preview@kiwicare.test",
                   phone: nil, avatarURL: nil, city: "Christchurch"),
        role: .customer
    )
}

extension Invoice {
    static let previewSamples: [Invoice] = [
        Invoice(id: UUID(), userID: "1", amount: 4500, paymentMethod: .cash,
                description: "Lawn mowing", createdAt: .now, syncStatus: .pending),
        Invoice(id: UUID(), userID: "1", amount: 12000, paymentMethod: .creditCard,
                description: "House cleaning", createdAt: .now.addingTimeInterval(-3600), syncStatus: .syncing),
        Invoice(id: UUID(), userID: "1", amount: 8000, paymentMethod: .bankTransfer,
                description: nil, createdAt: .now.addingTimeInterval(-86400), syncStatus: .synced),
        Invoice(id: UUID(), userID: "1", amount: 123456789, paymentMethod: .other,
                description: "A very long description to check how the row handles wrapping text",
                createdAt: .now.addingTimeInterval(-172800), syncStatus: .failed("Server rejected the invoice")),
    ]
}

struct PreviewFetchInvoices: FetchInvoicesUseCase {
    var invoices: [Invoice] = Invoice.previewSamples
    
    func execute(userID: String) throws -> [Invoice] {
        invoices
    }
}

struct PreviewCreateInvoice: CreateInvoiceUseCase {
    func execute(amount: Int, paymentMethod: PaymentMethod, description: String?) throws -> Invoice {
        Invoice(id: UUID(), userID: "1", amount: amount, paymentMethod: paymentMethod,
                description: description, createdAt: .now, syncStatus: .pending)
    }
}

#endif
