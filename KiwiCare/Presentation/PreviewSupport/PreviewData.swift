//
//  PreviewData.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

#if DEBUG

import Foundation
import SwiftUI

extension AuthSession {
    static let preview = AuthSession(
        user: User(id: "1", name: "Preview User", email: "preview@kiwicare.test",
                   phone: nil, avatarURL: nil, city: "Christchurch"),
        role: .customer
    )
}

extension Invoice {
    static let previewSamples: [Invoice] = [
        Invoice(id: UUID(), userID: "1", amount: 4500, paymentMethod: .cash,
                description: "Lawn mowing", createdAt: .now, syncStatus: .pending),
        Invoice(id: UUID(), userID: "1", amount: 12000, paymentMethod: .creditCard,
                description: "House cleaning", createdAt: .now.addingTimeInterval(-3600), syncStatus: .syncing),
        Invoice(id: UUID(), userID: "1", amount: 8000, paymentMethod: .bankTransfer,
                description: nil, createdAt: .now.addingTimeInterval(-86400), syncStatus: .synced),
        Invoice(id: UUID(), userID: "1", amount: 123456789, paymentMethod: .other,
                description: "A very long description to check how the row handles wrapping text",
                createdAt: .now.addingTimeInterval(-172800), syncStatus: .failed("Server rejected the invoice")),
    ]
}

extension NearbyProvider {
    static let previewSamples: [NearbyProvider] = [
        NearbyProvider(
            provider: Provider(
                id: UUID(), name: "Sparkle Cleaning", avatarURL: URL(string: "https://i.pravatar.cc/300?img=47"),
                address: "Halswell, Christchurch",
                coordinate: Coordinate(latitude: -43.585, longitude: 172.570),
                bio: "Home and office cleaning.", serviceRadiusKm: 15
            ),
            distanceKm: 1.2
        ),
        NearbyProvider(
            provider: Provider(
                id: UUID(), name: "Green Thumb Gardening", avatarURL: URL(string: "https://i.pravatar.cc/300?img=48"),
                address: "Riccarton, Christchurch",
                coordinate: Coordinate(latitude: -43.530, longitude: 172.600),
                bio: "Lawns, hedges and garden care.", serviceRadiusKm: 20
            ),
            distanceKm: 6.8
        ),
    ]
}

struct PreviewFetchInvoices: FetchInvoicesUseCase {
    var invoices: [Invoice] = Invoice.previewSamples
    
    func execute(userID: String) throws -> [Invoice] {
        invoices
    }

    /// 预览里发票不会变化：一个永远不发出事件的流
    func changes() -> AsyncStream<Void> {
        AsyncStream { _ in }
    }
}

struct PreviewCreateInvoice: CreateInvoiceUseCase {
    func execute(amount: Int, paymentMethod: PaymentMethod, description: String?, attachments: [URL]) throws -> Invoice {
        Invoice(id: UUID(), userID: "1", amount: amount, paymentMethod: paymentMethod,
                description: description, attachments: attachments, createdAt: .now, syncStatus: .pending)
    }
}

/// 模拟上传：每张图片 1 秒内进度走完，然后返回一个假的 URL
struct PreviewUploadAttachments: UploadAttachmentsUseCase {
    func execute(_ uploads: [AttachmentUpload]) -> AsyncStream<AttachmentUploadEvent> {
        AsyncStream { continuation in
            let task = Task {
                for upload in uploads {
                    for step in 1...10 {
                        try? await Task.sleep(for: .milliseconds(100))
                        continuation.yield(.progress(id: upload.id, fraction: Double(step) / 10))
                    }
                    continuation.yield(.completed(id: upload.id, url: URL(string: "https://example.com/\(upload.id).jpg")!))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

struct PreviewFetchNearbyProviders: FetchNearbyProvidersUseCase {
    var providers: [NearbyProvider] = NearbyProvider.previewSamples
    var locationSource: LocationSource = .current
    var error: Error? = nil

    func firstPage(keyword: String?) async throws -> NearbyProvidersPage {
        try await page(
            1,
            around: DefaultFetchNearbyProvidersUseCase.defaultLocation,
            locationSource: locationSource,
            keyword: keyword
        )
    }

    func page(
        _ page: Int,
        around location: Coordinate,
        locationSource: LocationSource,
        keyword: String?
    ) async throws -> NearbyProvidersPage {
        if let error { throw error }

        let filtered = providers.filter { item in
            guard let keyword, !keyword.isEmpty else { return true }
            return item.provider.name.localizedCaseInsensitiveContains(keyword)
        }

        return NearbyProvidersPage(
            providers: filtered,
            page: page,
            hasMore: false,
            location: location,
            locationSource: locationSource,
            keyword: keyword
        )
    }
}

struct PreviewRestoreSession: RestoreSessionUseCase {
    func execute() async throws -> AuthSession? {
        try await Task.sleep(for: .seconds(1))
        return .preview
    }
}

struct PreviewFetchInvoiceStats: FetchInvoiceStatsUseCase {
    func execute(userID: String) async throws -> InvoiceStats {
        try await Task.sleep(for: .seconds(1))
        return InvoiceStats(count: 4, totalAmount: 123_456, pendingCount: 2)
    }
}

struct ChineseLocale: PreviewModifier {
    func body(content: Content, context: Void) -> some View {
        content.environment(\.locale, Locale(identifier: "zh-Hans"))
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var chinese: Self { .modifier(ChineseLocale()) }
}

struct PreviewFetchProviderDetail: FetchProviderDetailUseCase {
    func execute(id: UUID) async throws -> Provider {
        try await Task.sleep(for: .seconds(1))
        return NearbyProvider.previewSamples[0].provider
    }
}

/// 预览用的页面工厂：所有页面都用假的 UseCase
nonisolated extension ScreenFactory {
    static let preview = ScreenFactory(
        invoiceList: {
            InvoiceListViewModel(useCase: PreviewFetchInvoices(), userID: "1")
        },
        createInvoice: {
            CreateInvoiceViewModel(
                createInvoice: PreviewCreateInvoice(),
                uploadAttachments: PreviewUploadAttachments(),
                onCreated: { _ in }
            )
        },
        nearbyProviders: {
            NearbyProvidersViewModel(fetchNearbyProviders: PreviewFetchNearbyProviders())
        },
        profile: {
            ProfileViewModel(
                restoreSession: PreviewRestoreSession(),
                fetchInvoiceStats: PreviewFetchInvoiceStats(),
                userID: "1"
            )
        },
        providerDetail: {
            ProviderDetailViewController(item: $0, fetchDetail: PreviewFetchProviderDetail())
        }
    )
}

#endif
