//
//  ScreenFactory.swift
//  KiwiCare
//

import SwiftUI

/// 创建各个页面需要的 ViewModel / ViewController。
/// 通过 SwiftUI 的 Environment 传递：在 RootView 注入一次，用到的页面直接读取，
/// 中间的视图（MainTabView 等）不需要一层层转发。
nonisolated struct ScreenFactory: Sendable {
    var invoiceList: @MainActor @Sendable () -> InvoiceListViewModel
    var createInvoice: @MainActor @Sendable () -> CreateInvoiceViewModel
    var nearbyProviders: @MainActor @Sendable () -> NearbyProvidersViewModel
    var profile: @MainActor @Sendable () -> ProfileViewModel
    var providerDetail: @MainActor @Sendable (NearbyProvider) -> ProviderDetailViewController
}

nonisolated extension EnvironmentValues {
    /// 默认值会直接崩溃，提醒你忘了注入（App 里在 RootView 注入，预览里注入 .preview）
    @Entry var screenFactory: ScreenFactory = .unimplemented
}

nonisolated extension ScreenFactory {
    static let unimplemented = ScreenFactory(
        invoiceList: { fatalError("ScreenFactory not injected") },
        createInvoice: { fatalError("ScreenFactory not injected") },
        nearbyProviders: { fatalError("ScreenFactory not injected") },
        profile: { fatalError("ScreenFactory not injected") },
        providerDetail: { _ in fatalError("ScreenFactory not injected") }
    )
}
