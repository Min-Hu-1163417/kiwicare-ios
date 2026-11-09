//
//  AttachmentRepository.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

protocol AttachmentRepository {
    func upload(
        _ imageData: Data,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws -> URL
}
