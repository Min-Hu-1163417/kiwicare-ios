//
//  AppContainer.swift
//  KiwiCare
//

/// Composition root: the only place that creates concrete implementations
/// and wires them together.

import SwiftData

final class AppContainer {
    let session: SessionViewModel
    let invoiceSync: InvoiceSyncCoordinator
    
    private let signInUseCase: SignInUseCase
    private let invoiceUseCase: DefaultFetchInvoicesUseCase
    private let createInvoiceUseCase: DefaultCreateInvoiceUseCase
    private let fetchNearbyProvider: FetchNearbyProvidersUseCase
    private let fetchProviderDetail: FetchProviderDetailUseCase
    private let uploadAttachments: UploadAttachmentsUseCase
    private let fetchInvoiceStats : FetchInvoiceStatsUseCase
    private let restoreSession: RestoreSessionUseCase
    
    private let invoiceRepository: InvoiceRepository
    
    init() {
        // Data
        let tokenStore = KeychainTokenStore()
        let client = APIClient()
        client.tokenProvider = { [tokenStore] in tokenStore.token }
        let authRepository = DefaultAuthRepository(client: client, tokenStore: tokenStore)
        
        // Domain
        let signIn = DefaultSignInUseCase(repository: authRepository)
        let restoreSession = DefaultRestoreSessionUseCase(repository: authRepository)
        let signOut = DefaultSignOutUseCase(repository: authRepository)
        
        // Presentation
        let session = SessionViewModel(restoreSession: restoreSession, signOut: signOut)
        // weak: session -> use case -> repository -> client -> this closure would otherwise form a cycle
        client.onUnauthorized = { [weak session] in session?.signOut()
        }
        
        let modelContainer = try! ModelContainer(for: InvoiceRecord.self)
        let localInvoiceStore = LocalInvoiceStore(container: modelContainer)
        
        try? localInvoiceStore.resetInterruptedSyncs()
        
        let invoiceRepository = DefaultInvoiceRepository(local: localInvoiceStore, client: client)
        let invoiceUseCase = DefaultFetchInvoicesUseCase(repository: invoiceRepository)
        
        self.invoiceRepository = invoiceRepository
        self.invoiceSync = InvoiceSyncCoordinator(
            syncInvoices: DefaultSyncInvoicesUseCase(repository: invoiceRepository),
            networkMonitor: NetworkMonitor()
        )
        
        self.createInvoiceUseCase = DefaultCreateInvoiceUseCase(
            repo: invoiceRepository,
            currentUserID: { [weak session] in
                guard case .signedIn(let authSession) = session?.state else { return nil }
                return authSession.user.id
            }
        )
        
        let providerRepository = DefaultProviderRepository(client: client)
        self.fetchNearbyProvider = DefaultFetchNearbyProvidersUseCase(repository: providerRepository, locationProvider: CoreLocationProvider())
        self.fetchProviderDetail = DefaultFetchProviderDetailUseCase(repository: providerRepository)
        
        // Attachments
        let attachmentRepository = DefaultAttachmentRepository(client: client)
        self.uploadAttachments = DefaultUploadAttachmentsUseCase(repository: attachmentRepository)
        
        self.fetchInvoiceStats = DefaultFetchInvoiceStatsUseCase(repository: invoiceRepository)
        
        self.session = session
        self.signInUseCase = signIn
        self.invoiceUseCase = invoiceUseCase
        self.restoreSession = restoreSession
    }
}

extension AppContainer {
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(signIn: signInUseCase) { [session] authSession in
            session.didSignIn(authSession)
        }
    }
    
    func makeInvoiceListViewModel(userID: String) -> InvoiceListViewModel {
        InvoiceListViewModel(useCase: invoiceUseCase, userID: userID)
    }
    
    func makeCreateInvoiceViewModel() -> CreateInvoiceViewModel {
        CreateInvoiceViewModel(createInvoice: createInvoiceUseCase, uploadAttachments: uploadAttachments) { [weak self] _ in
            // 列表会通过 Repository 的变化通知自动刷新，这里只需要触发上传
            self?.invoiceSync.requestSync()
        }
    }
    
    func makeNearbyProvidersViewModel() -> NearbyProvidersViewModel {
        NearbyProvidersViewModel(fetchNearbyProviders: fetchNearbyProvider)
    }
    
    func makeProfileViewModel(userID: String) -> ProfileViewModel {
        ProfileViewModel(restoreSession: self.restoreSession, fetchInvoiceStats: self.fetchInvoiceStats, userID: userID)
    }
    
    func makeProviderDetail(_ item: NearbyProvider) -> ProviderDetailViewController {
        ProviderDetailViewController(item: item, fetchDetail: fetchProviderDetail)
    }
    
    /// 登录后的所有页面工厂，在 RootView 里通过 Environment 注入
    func screenFactory(userID: String) -> ScreenFactory {
        ScreenFactory(
            invoiceList: { self.makeInvoiceListViewModel(userID: userID) },
            createInvoice: { self.makeCreateInvoiceViewModel() },
            nearbyProviders: { self.makeNearbyProvidersViewModel() },
            profile: { self.makeProfileViewModel(userID: userID) },
            providerDetail: { self.makeProviderDetail($0) }
        )
    }
}
