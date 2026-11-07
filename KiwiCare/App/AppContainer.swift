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
    private var invoiceList: (userID: String, viewModel: InvoiceListViewModel)?
    
    private let signInUseCase: SignInUseCase
    private let invoiceUseCase: DefaultFetchInvoicesUseCase
    private let createInvoiceUseCase: DefaultCreateInvoiceUseCase
    
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
        
        self.session = session
        self.signInUseCase = signIn
        self.invoiceUseCase = invoiceUseCase
    }
}

extension AppContainer {
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(signIn: signInUseCase) { [session] authSession in
            session.didSignIn(authSession)
        }
    }
    
    func makeInvoiceListViewModel(userID: String) -> InvoiceListViewModel {
        let viewModel = InvoiceListViewModel(useCase: invoiceUseCase, userID: userID)
        invoiceSync.onSyncFinished = { [weak viewModel] in viewModel?.load() }
        return viewModel
    }
    
    func makeCreateInvoiceViewModel() -> CreateInvoiceViewModel {
        CreateInvoiceViewModel(createInvoice: createInvoiceUseCase) { [weak self] _ in
            self?.invoiceList?.viewModel.load()      // 列表立刻显示新发票
            self?.invoiceSync.requestSync()          // 触发上传
        }
    }
}
