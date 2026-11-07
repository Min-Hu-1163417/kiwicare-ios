//
//  LocalInvoiceStore.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation
import SwiftData

final class LocalInvoiceStore {
    private let container: ModelContainer
    private let context: ModelContext
    
    init(container: ModelContainer) {
        self.container = container
        context = container.mainContext
    }
    
    func insert(_ invoice: Invoice) throws {
        context.insert(InvoiceRecord(invoice))
        try context.save()
    }
    
    func invoices(for userID: String) throws -> [Invoice] {
        let descriptor = FetchDescriptor<InvoiceRecord>(
            predicate: #Predicate{ $0.userID == userID },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).compactMap {
            $0.toDomain()
        }
    }
    
    func pendingInvoices() throws -> [Invoice] {
        let pending = SyncStatus.pending.stateCode
        let descriptor = FetchDescriptor<InvoiceRecord>(
            predicate: #Predicate { $0.syncState == pending },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        
        return try context.fetch(descriptor).compactMap {
            $0.toDomain()
        }
    }
    
    func updateStatus(id: UUID, to status: SyncStatus) throws {
        guard let record = try record(id: id) else {
            return
        }
        
        record.apply(status)
        try context.save()
    }
    
    /// App 启动时调用：把卡在"上传中"的记录重置为"待上传"
    func resetInterruptedSyncs() throws {
        let syncing = SyncStatus.syncing.stateCode
        let descriptor = FetchDescriptor<InvoiceRecord>(
            predicate: #Predicate { $0.syncState == syncing }
        )
        
        for record in try context.fetch(descriptor) {
            record.apply(.pending)
        }
        try context.save()
    }
    
    func recordFailedAttempt(id: UUID) throws -> Int {
        guard let record = try record(id: id) else { return 0 }
        record.attemptCount += 1
        try context.save()
        return record.attemptCount
    }
    
    private func record(id: UUID) throws -> InvoiceRecord? {
        let descriptor = FetchDescriptor<InvoiceRecord>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }
}
