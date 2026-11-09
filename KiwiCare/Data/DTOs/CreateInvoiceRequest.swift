//
//  CreateInvoiceRequest.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation

struct CreateInvoiceRequest: Encodable {
    struct UserReference: Encodable {
        let id: String
    }

    let id: String
    let user: UserReference
    let amount: Int
    let paymentMethod: String
    let description: String?
    let attachments: [String]
    let source: String

    init(_ invoice: Invoice) {
        id = invoice.id.uuidString.lowercased()
        user = UserReference(id: invoice.userID)
        amount = invoice.amount
        paymentMethod = invoice.paymentMethod.rawValue
        description = invoice.description
        attachments = invoice.attachments.map(\.absoluteString)
        source = "manual"
    }
}
