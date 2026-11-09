//
//  NearbyProvidersView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import SwiftUI
import OSLog

struct NearbyProvidersView: View {
    @State private var viewModel: NearbyProvidersViewModel
    @Environment(\.screenFactory) private var screenFactory
    
    @Environment(\.openURL) private var openURL
    
    private enum DisplayMode {
        case list
        case map
    }
    
    @State private var displayMode: DisplayMode = .list
    @State private var selectedProviderID: UUID?
    @State private var invoiceProvider: NearbyProvider?
    
    init(viewModel: NearbyProvidersViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        content
            .navigationTitle(displayMode == .list ? "Nearby" : "")
            .navigationDestination(for: NearbyProvider.self, destination: { item in
                ProviderDetailView(
                    makeViewController: { screenFactory.providerDetail(item) },
                    onCreateInvoice: { invoiceProvider = $0 }
                )
                .navigationTitle(item.provider.name)
                .navigationBarTitleDisplayMode(.inline)
            })
            .navigationBarTitleDisplayMode(displayMode == .list ? .large : .inline)
            .toolbar {
                if viewModel.isSearching {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            displayMode = displayMode == .list ? .map : .list
                        }
                    } label: {
                        if displayMode == .list {
                            Label("Map", systemImage: "map")
                        } else {
                            Label("List", systemImage: "list.bullet")
                        }
                    }
                    
                }
            }
            .sheet(item: $invoiceProvider) { provider in
                NavigationStack {
                    CreateInvoiceView(viewModel: makeCreateInvoiceViewModel(for: provider))
                }
            }
            .task {
                await viewModel.loadIfNeeded()
            }
            .task(id: viewModel.searchText) {
                if viewModel.searchText.isEmpty {
                    await viewModel.search()
                    return
                }
                
                Logger.providers.debug("⏱ task start '\(viewModel.searchText)'")
                do {
                    try await Task.sleep(for: .milliseconds(300))
                } catch {
                    Logger.providers.debug("⏱ task cancelled during sleep")
                    return
                }
                await viewModel.search()
                Logger.providers.debug("⏱ task finished '\(viewModel.searchText)'")
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded:
            switch displayMode {
            case .list: providerList
            case .map: providerMap
            }
        case .fail(let message):
            ContentUnavailableView {
                Label("Couldn't load providers", systemImage: "wifi.exclamationmark")
                
            } description: {
                Text(message)
            } actions: {
                Button("Retry") {
                    Task {
                        await viewModel.retry()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var providerMap: some View {
        ProvidersMap(providers: viewModel.providers, selectedID: $selectedProviderID)
            .safeAreaInset(edge: .bottom) {
                if let item = selectedProvider {
                    NearbyProviderRow(item: item)
                        .padding()
                        .background(.regularMaterial, in: .rect(cornerRadius: 16))
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.3), value: selectedProviderID)
    }
    
    private func makeCreateInvoiceViewModel(for provider: NearbyProvider) -> CreateInvoiceViewModel {
        let viewModel = screenFactory.createInvoice()
        viewModel.note = String(localized: "Service by \(provider.provider.name)")
        return viewModel
    }
    
    private var selectedProvider: NearbyProvider? {
        viewModel.providers.first { $0.id == selectedProviderID }
    }
    
    private var providerList: some View {
        List {
            if let notice = viewModel.locationNotice {
                Section {
                    locationNoticeRow(notice)
                }
            }
            ForEach(viewModel.providers) { item in
                NavigationLink(value: item) {
                    NearbyProviderRow(item: item)
                        .onAppear {
                            if item.id == viewModel.providers.last?.id {
                                Task {
                                    await viewModel.loadMore()
                                }
                            }
                        }
                }
            }
            
            loadMoreFooter
        }
        .overlay {
            if viewModel.providers.isEmpty {
                if viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        "No providers nearby",
                        systemImage: "mappin.slash",
                        description: Text("Pull down to try again.")
                    )
                } else {
                    ContentUnavailableView.search(text: viewModel.searchText)
                }
            }
        }
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search providers")
        .refreshable {
            await viewModel.load()
        }
    }
    
    private func locationNoticeRow(_ notice: LocalizedStringResource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(notice, systemImage: "location.slash")
                .font(.subheadline)
            if viewModel.canOpenSettings {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .font(.subheadline.bold())
            }
        }
    }
    
    @ViewBuilder
    private var loadMoreFooter: some View {
        if viewModel.isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
        } else if viewModel.loadMoreFailed {
            Button("Couldn't load more. Tap to retry") {
                Task { await viewModel.loadMore() }
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
        }
    }
}

#if DEBUG

private func makeNearbyPreview(_ useCase: PreviewFetchNearbyProviders = .init()) -> some View {
    NavigationStack {
        NearbyProvidersView(viewModel: NearbyProvidersViewModel(fetchNearbyProviders: useCase))
    }
    .environment(\.screenFactory, .preview)
}

#Preview("Loaded") {
    makeNearbyPreview()
}

#Preview("Location denied") {
    makeNearbyPreview(.init(locationSource: .fallback(.denied)))
}

#Preview("Empty") {
    makeNearbyPreview(.init(providers: []))
}

#Preview("Error") {
    makeNearbyPreview(.init(error: ProviderError.network))
}

#Preview("中文") {
    makeNearbyPreview(.init(locationSource: .fallback(.denied)))
        .environment(\.locale, Locale(identifier: "zh-Hans"))
}

#endif
