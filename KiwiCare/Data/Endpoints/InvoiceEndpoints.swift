//
//  InvoiceEndpoints.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

extension Endpoint where Response == InvoiceCreatedResponse {
    static func createInvoice(_ request: CreateInvoiceRequest) -> Self {
        .init(path: "invoices", method: .post, body: request)
    }
}
