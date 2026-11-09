//
//  Invoice.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation

nonisolated struct Invoice: Identifiable, Equatable {
    let id: UUID
    let userID: String
    let amount: Int
    let paymentMethod: PaymentMethod
    let description: String?
    var attachments: [URL] = []     // 附件图片的 URL（已上传到服务器）
    let createdAt: Date
    var syncStatus: SyncStatus
}

nonisolated enum PaymentMethod: String, CaseIterable {
    case cash
    case creditCard = "credit_card"
    case bankTransfer = "bank_transfer"
    case other
}

nonisolated enum SyncStatus: Equatable {
    case pending                    // 等待上传
    case syncing                    // 上传中
    case synced                     // 已上传
    case failed(String)             // 上传失败，数据有问题，需要用户处理
}
