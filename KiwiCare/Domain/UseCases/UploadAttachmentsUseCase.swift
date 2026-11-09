//
//  UploadAttachmentsUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

protocol UploadAttachmentsUseCase {
    func execute(_ uploads: [AttachmentUpload]) -> AsyncStream<AttachmentUploadEvent>
}

final class DefaultUploadAttachmentsUseCase: UploadAttachmentsUseCase {
    static let maxConcurrentUploads = 3

    private let repository: AttachmentRepository

    init(repository: AttachmentRepository) {
        self.repository = repository
    }

    func execute(_ uploads: [AttachmentUpload]) -> AsyncStream<AttachmentUploadEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: AttachmentUploadEvent.self)

        let task = Task {
            await withTaskGroup(of: Void.self) { group in
                var pending = uploads.makeIterator()

                // 先启动最多 3 个
                for _ in 0..<Self.maxConcurrentUploads {
                    guard let upload = pending.next() else { break }
                    group.addTask { await self.upload(upload, continuation: continuation) }
                }

                // 每完成一个，就补上一个
                for await _ in group {
                    guard let upload = pending.next() else { continue }
                    group.addTask { await self.upload(upload, continuation: continuation) }
                }
            }
            continuation.finish()
        }

        // 页面不再接收事件时（比如关闭了页面），取消所有上传
        continuation.onTermination = { _ in task.cancel() }

        return stream
    }

    private func upload(
        _ item: AttachmentUpload,
        continuation: AsyncStream<AttachmentUploadEvent>.Continuation
    ) async {
        do {
            let url = try await repository.upload(item.data) { fraction in
                continuation.yield(.progress(id: item.id, fraction: fraction))
            }
            continuation.yield(.completed(id: item.id, url: url))
        } catch {
            if Task.isCancelled { return }
            continuation.yield(.failed(id: item.id, error: error as? AttachmentError ?? .unknown))
        }
    }
}
