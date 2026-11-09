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
    /// 每个观察者一个 continuation
    private var changeContinuations: [UUID: AsyncStream<Void>.Continuation] = [:]
    
    init(local: LocalInvoiceStore, client: HTTPClient) {
        self.local = local
        self.client = client
    }
    
    func save(_ invoice: Invoice) throws {
        do {
            try local.insert(invoice)
            notifyChanged()
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
            updateStatus(id: invoice.id, to: .syncing)
            
            do {
                _ = try await client.send(.createInvoice(CreateInvoiceRequest(invoice)))
                updateStatus(id: invoice.id, to: .synced)
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
            updateStatus(id: id, to: .pending)
            return false

        case APIError.server(let status, let message) where (400..<500).contains(status):
            // 服务器明确拒绝了这条数据，重试也没用
            updateStatus(id: id, to: .failed(message))
            return true

        default:
            // 服务器错误等其他情况：计入失败次数，次数用完就不再自动重试
            let attempts = (try? local.recordFailedAttempt(id: id)) ?? maxAttempts
            let status: SyncStatus = attempts >= maxAttempts
                ? .failed("Upload failed after \(attempts) attempts.")
                : .pending
            updateStatus(id: id, to: status)
            return true
        }
    }

    // MARK: - 变化通知

    func changes() -> AsyncStream<Void> {
        // 只保留最新的一个事件：列表还没来得及处理时又变了，合并成一次重新加载就够了
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(1))
        let id = UUID()
        changeContinuations[id] = continuation

        // 观察者停止监听（页面消失、任务被取消）时，把它移除
        continuation.onTermination = { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.removeChangeContinuation(id) }
        }
        return stream
    }

    private func removeChangeContinuation(_ id: UUID) {
        changeContinuations[id] = nil
    }

    private func notifyChanged() {
        for continuation in changeContinuations.values {
            continuation.yield()
        }
    }

    /// 更新本地的同步状态，并通知观察者
    private func updateStatus(id: UUID, to status: SyncStatus) {
        try? local.updateStatus(id: id, to: status)
        notifyChanged()
    }
}
