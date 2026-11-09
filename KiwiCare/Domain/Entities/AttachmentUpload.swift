//
//  AttachmentUpload.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

nonisolated struct AttachmentUpload: Identifiable, Sendable {
    let id: UUID
    let data: Data
}

nonisolated enum AttachmentUploadEvent: Equatable, Sendable {
    case progress(id: UUID, fraction: Double)
    case completed(id: UUID, url: URL)
    case failed(id: UUID, error: AttachmentError)
}
