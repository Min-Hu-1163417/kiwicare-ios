//
//  UploadEndpoints.swift
//  KiwiCare
//

extension Endpoint where Response == UploadResponse {
    /// 上传一张图片，multipart 字段名是 "file"
    static var uploadImage: Self {
        .init(path: "upload", method: .post)
    }
}
