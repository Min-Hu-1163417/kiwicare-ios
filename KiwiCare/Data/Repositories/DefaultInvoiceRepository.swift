//
//  DefaultInvoiceRepository.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation

final class DefaultInvoiceRepository: InvoiceRepository {
    private let local: LocalInvoiceStore
    private let client: HTTPClient
    private let maxAttempts = 5
    private var isSyncing = false
    
    init(local: LocalInvoiceStore, client: HTTPClient) {
        self.local = local
        self.client = client
    }
    
    func save(_ invoice: Invoice) throws {
        do {
            try local.insert(invoice)
        } catch {
            throw InvoiceError.storageFailed
        }
    }
    
    func invoices(for userID: String) throws -> [Invoice] {
        do {
            return try local.invoices(for: userID)
        } catch {
            throw InvoiceError.storageFailed
        }
    }
    
    func syncPending() async {
        guard !isSyncing else {
            return
        }
        
        isSyncing = true
        
        defer {
            isSyncing = false
        }
        
        guard let pending = try? local.pendingInvoices() else { return }
        
        for invoice in pending {
            try? local.updateStatus(id: invoice.id, to: .syncing)
            
            do {
                _ = try await client.send(.createInvoice(CreateInvoiceRequest(invoice)))
                try? local.updateStatus(id: invoice.id, to: .synced)
            } catch {
                let shouldContinue = handleUploadFailure(error, for: invoice.id)
                if shouldContinue {
                    return
                }
            }
        }
    }
    
    /// 返回值表示：要不要继续上传下一张发票
    private func handleUploadFailure(_ error: Error, for id: UUID) -> Bool {
        switch error {
        case APIError.network, APIError.unauthorized:
            // 断网，或者登录失效：放回待上传，不计入失败次数，停止这一轮同步
            try? local.updateStatus(id: id, to: .pending)
            return false

        case APIError.server(let status, let message) where (400..<500).contains(status):
            // 服务器明确拒绝了这条数据，重试也没用
            try? local.updateStatus(id: id, to: .failed(message))
            return true

        default:
            // 服务器错误等其他情况：计入失败次数，次数用完就不再自动重试
            let attempts = (try? local.recordFailedAttempt(id: id)) ?? maxAttempts
            let status: SyncStatus = attempts >= maxAttempts
                ? .failed("Upload failed after \(attempts) attempts.")
                : .pending
            try? local.updateStatus(id: id, to: status)
            return true
        }
    }
}
