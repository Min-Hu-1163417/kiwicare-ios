//
//  ImageCompressor.swift
//  KiwiCare
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

nonisolated enum ImageCompressor {
    /// 把任意格式的图片缩小、转成 JPEG，保证不超过 maxBytes
    /// 在后台线程执行；只写入像素，原图的 EXIF（包括 GPS 位置）不会被带上
    @concurrent
    static func jpeg(from data: Data, maxPixelSize: Int, maxBytes: Int) async throws -> Data {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw AttachmentError.invalidImage
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ] as CFDictionary

        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            throw AttachmentError.invalidImage
        }

        // 先用较高的质量，超过大小限制就降低质量再试
        for quality in [0.8, 0.6, 0.4] {
            try Task.checkCancellation()

            let output = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(
                output as CFMutableData, UTType.jpeg.identifier as CFString, 1, nil
            ) else {
                throw AttachmentError.invalidImage
            }

            let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
            CGImageDestinationAddImage(destination, image, options)

            guard CGImageDestinationFinalize(destination) else {
                throw AttachmentError.invalidImage
            }
            if output.length <= maxBytes {
                return output as Data
            }
        }
        throw AttachmentError.tooLarge
    }
}
