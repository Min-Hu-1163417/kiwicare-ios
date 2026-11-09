//
//  DefaultAttachmentRepository.swift
//  KiwiCare
//

import Foundation

final class DefaultAttachmentRepository: AttachmentRepository {
    /// 最长边 2048 像素，看发票足够清楚
    static let maxPixelSize = 2048
    /// 后端限制 5 MB，留一点余量
    static let maxBytes = 4 * 1024 * 1024

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func upload(
        _ imageData: Data,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws -> URL {
        do {
            // 压缩在后台线程执行（@concurrent）
            let jpeg = try await ImageCompressor.jpeg(
                from: imageData,
                maxPixelSize: Self.maxPixelSize,
                maxBytes: Self.maxBytes
            )
            let file = MultipartFile(
                fieldName: "file",
                fileName: "\(UUID().uuidString.lowercased()).jpg",
                mimeType: "image/jpeg",
                data: jpeg
            )
            let response: UploadResponse = try await client.upload(.uploadImage, file: file, onProgress: onProgress)
            return response.url
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> AttachmentError {
        switch error {
        case let error as AttachmentError:
            error
        case APIError.network:
            .network
        case APIError.unauthorized:
            .sessionExpired
        case APIError.server(status: 413, _):
            .tooLarge
        case APIError.server(status: 400, _):
            .invalidImage
        default:
            .unknown
        }
    }
}
