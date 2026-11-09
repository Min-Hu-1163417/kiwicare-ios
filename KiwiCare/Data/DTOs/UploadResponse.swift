//
//  UploadResponse.swift
//  KiwiCare
//

import Foundation

/// POST /upload 的响应：{ "key": "...", "url": "http://..." }
nonisolated struct UploadResponse: Decodable {
    let key: String
    let url: URL
}
