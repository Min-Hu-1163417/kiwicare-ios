//
//  AttachmentError.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

nonisolated enum AttachmentError: Error, Equatable, Sendable {
    case invalidImage     // 不是有效的图片，无法压缩
    case tooLarge         // 压缩后还是超过 5 MB
    case network
    case sessionExpired
    case unknown
}
