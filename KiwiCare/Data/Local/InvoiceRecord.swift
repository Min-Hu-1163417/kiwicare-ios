//
//  InvoiceRecord.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation
import SwiftData

@Model
final class InvoiceRecord {
    @Attribute(.unique) var id: UUID
    var userID: String
    var amount: Int
    var paymentMethod: String
    var note: String?
    var createdAt: Date
    var syncState: String           // "pending" / "syncing" / "synced" / "failed"
    var failureReason: String?
    var attemptCount = 0
    
    init(id: UUID, userID: String, amount: Int, paymentMethod: String,
         note: String?, createdAt: Date, syncState: String, failureReason: String?) {
        self.id = id
        self.userID = userID
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.note = note
        self.createdAt = createdAt
        self.syncState = syncState
        self.failureReason = failureReason
    }
}

extension InvoiceRecord {
    convenience init(_ invoice: Invoice) {
        self.init(
            id: invoice.id,
            userID: invoice.userID,
            amount: invoice.amount,
            paymentMethod: invoice.paymentMethod.rawValue,
            note: invoice.description,
            createdAt: invoice.createdAt,
            syncState: invoice.syncStatus.stateCode,
            failureReason: invoice.syncStatus.failureReason
        )
    }
    
    func toDomain() -> Invoice? {
        guard let method = PaymentMethod(rawValue: paymentMethod) else { return nil }
        return Invoice(
            id: id,
            userID: userID,
            amount: amount,
            paymentMethod: method,
            description: note,
            createdAt: createdAt,
            syncStatus: SyncStatus(stateCode: syncState, failureReason: failureReason)
        )
    }
    
    func apply(_ status: SyncStatus) {
        syncState = status.stateCode
        failureReason = status.failureReason
    }
}

nonisolated extension SyncStatus {
    var stateCode: String {
        switch self {
        case .pending: "pending"
        case .syncing: "syncing"
        case .synced: "synced"
        case .failed: "failed"
        }
    }

    var failureReason: String? {
        if case .failed(let reason) = self { return reason }
        return nil
    }

    init(stateCode: String, failureReason: String?) {
        switch stateCode {
        case "syncing": self = .syncing
        case "synced": self = .synced
        case "failed": self = .failed(failureReason ?? "Unknown error")
        default: self = .pending
        }
    }
}
