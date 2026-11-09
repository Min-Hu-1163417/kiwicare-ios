//
//  CreateInvoiceViewModel.swift
//  KiwiCare
//

import Foundation
import Observation

@Observable
final class CreateInvoiceViewModel {
    struct Attachment: Identifiable, Equatable {
        enum Status: Equatable {
            case uploading(progress: Double)   // progress 为 0 时表示还在排队
            case uploaded(URL)
            case failed(String)

            var isUploading: Bool {
                if case .uploading = self { return true }
                return false
            }

            var isFailed: Bool {
                if case .failed = self { return true }
                return false
            }

            var url: URL? {
                if case .uploaded(let url) = self { return url }
                return nil
            }
        }

        let id: UUID
        let data: Data
        var status: Status
    }

    static let maxAttachments = 6

    var amountText = ""
    var paymentMethod: PaymentMethod = .cash
    var note = ""
    private(set) var errorMessage: String?
    private(set) var attachments: [Attachment] = []

    /// 每次添加或重试都会开始一批上传，这里保存它们，页面关闭时统一取消
    private var uploadTasks: [Task<Void, Never>] = []

    private let createInvoice: CreateInvoiceUseCase
    private let uploadAttachments: UploadAttachmentsUseCase
    private let onCreated: (Invoice) -> Void

    init(
        createInvoice: CreateInvoiceUseCase,
        uploadAttachments: UploadAttachmentsUseCase,
        onCreated: @escaping (Invoice) -> Void
    ) {
        self.createInvoice = createInvoice
        self.uploadAttachments = uploadAttachments
        self.onCreated = onCreated
    }

    // MARK: - 状态

    var canSave: Bool {
        amountInCents != nil && !isUploading && !hasFailedUploads
    }

    var isUploading: Bool {
        attachments.contains { $0.status.isUploading }
    }

    var hasFailedUploads: Bool {
        attachments.contains { $0.status.isFailed }
    }

    var remainingAttachmentSlots: Int {
        max(Self.maxAttachments - attachments.count, 0)
    }

    /// 显示在图片下方的提示
    var attachmentHint: String? {
        if let failed = attachments.first(where: { $0.status.isFailed }),
           case .failed(let reason) = failed.status {
            return String(localized: "\(reason) Tap ↻ to retry, or remove the photo.")
        }
        if isUploading {
            let done = attachments.filter { $0.status.url != nil }.count
            return String(localized: "Uploading photos… \(done) of \(attachments.count) done.")
        }
        return nil
    }

    // MARK: - 图片

    func addAttachments(_ images: [Data]) {
        let newItems = images.prefix(remainingAttachmentSlots).map {
            Attachment(id: UUID(), data: $0, status: .uploading(progress: 0))
        }
        guard !newItems.isEmpty else { return }

        attachments += newItems
        startUploading(Array(newItems))
    }

    func retryAttachment(id: UUID) {
        guard let index = index(of: id), attachments[index].status.isFailed else { return }
        attachments[index].status = .uploading(progress: 0)
        startUploading([attachments[index]])
    }

    func removeAttachment(id: UUID) {
        // 正在上传的图片被删除时，上传会继续完成，但结果会被忽略（handle 里找不到这个 id）
        attachments.removeAll { $0.id == id }
    }

    /// 页面关闭时调用：取消所有还没完成的上传
    func cancelUploads() {
        uploadTasks.forEach { $0.cancel() }
        uploadTasks.removeAll()
    }

    private func startUploading(_ items: [Attachment]) {
        let uploads = items.map { AttachmentUpload(id: $0.id, data: $0.data) }
        let stream = uploadAttachments.execute(uploads)

        // 这个任务被取消时，for await 会结束，stream 终止，
        // UseCase 的 onTermination 就会取消正在进行的上传
        let task = Task { [weak self] in
            for await event in stream {
                self?.handle(event)
            }
        }
        uploadTasks.append(task)
    }

    private func handle(_ event: AttachmentUploadEvent) {
        switch event {
        case .progress(let id, let fraction):
            // 只更新还在上传中的，避免已完成的又变回上传中
            guard let index = index(of: id), attachments[index].status.isUploading else { return }
            attachments[index].status = .uploading(progress: fraction)

        case .completed(let id, let url):
            guard let index = index(of: id) else { return }
            attachments[index].status = .uploaded(url)

        case .failed(let id, let error):
            guard let index = index(of: id) else { return }
            attachments[index].status = .failed(Self.message(for: error))
        }
    }

    private func index(of id: UUID) -> Int? {
        attachments.firstIndex { $0.id == id }
    }

    // MARK: - 保存

    func save() -> Bool {
        guard let amount = amountInCents else {
            errorMessage = Self.message(for: .invalidAmount)
            return false
        }

        let urls = attachments.compactMap(\.status.url)
        guard urls.count == attachments.count else {
            errorMessage = String(localized: "Please wait until all photos are uploaded.")
            return false
        }

        do {
            let invoice = try createInvoice.execute(
                amount: amount,
                paymentMethod: paymentMethod,
                description: note,
                attachments: urls
            )
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
        case .invalidAmount: String(localized: "Please enter an amount greater than 0.")
        case .notSignedIn: String(localized: "You need to sign in again.")
        case .storageFailed: String(localized: "Couldn't save the invoice. Please try again.")
        }
    }

    private static func message(for error: AttachmentError) -> String {
        switch error {
        case .invalidImage: String(localized: "A photo couldn't be read.")
        case .tooLarge: String(localized: "A photo is too large.")
        case .network: String(localized: "A photo failed to upload because of a network problem.")
        case .sessionExpired: String(localized: "Your session has expired.")
        case .unknown: String(localized: "A photo failed to upload.")
        }
    }
}
