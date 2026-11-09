//
//  AttachmentCell.swift
//  KiwiCare
//

import ImageIO
import SwiftUI

/// 创建发票页面里的一张图片：缩略图 + 上传进度 / 重试 + 删除按钮
struct AttachmentCell: View {
    let attachment: CreateInvoiceViewModel.Attachment
    let onRetry: () -> Void
    let onRemove: () -> Void

    static let size: CGFloat = 80

    var body: some View {
        AttachmentThumbnail(data: attachment.data, size: Self.size)
            .overlay { statusOverlay }
            .clipShape(.rect(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.6))
                }
                .buttonStyle(.borderless)
                .padding(4)
                .accessibilityLabel("Remove photo")
            }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        switch attachment.status {
        case .uploading(let progress):
            ZStack {
                Color.black.opacity(0.35)
                ProgressRing(progress: progress)
                    .frame(width: 28, height: 28)
            }

        case .uploaded:
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .green)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(6)

        case .failed:
            ZStack {
                Color.black.opacity(0.45)
                Button(action: onRetry) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .red)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Retry upload")
            }
        }
    }
}

private struct ProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.3), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .animation(.linear(duration: 0.15), value: progress)
    }
}

/// 在后台把原图缩小成缩略图，避免在主线程解码几 MB 的照片
private struct AttachmentThumbnail: View {
    let data: Data
    let size: CGFloat

    @Environment(\.displayScale) private var displayScale
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle().fill(.quaternary)
            }
        }
        .frame(width: size, height: size)
        .task {
            image = await Self.thumbnail(from: data, maxPixelSize: size * displayScale)
        }
    }

    @concurrent
    nonisolated static func thumbnail(from data: Data, maxPixelSize: CGFloat) async -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
