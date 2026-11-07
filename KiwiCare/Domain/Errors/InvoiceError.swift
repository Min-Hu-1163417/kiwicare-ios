//
//  InvoiceError.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

enum InvoiceError: Error, Equatable {
    case invalidAmount
    case notSignedIn
    case storageFailed
}
