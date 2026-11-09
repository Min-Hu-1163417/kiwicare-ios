//
//  Untitled.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation
import Observation
import OSLog

@Observable
final class NearbyProvidersViewModel {
    enum State: Equatable {
        case loading
        case loaded
        case fail(String)
    }
    
    private(set) var state: State = .loading
    private(set) var providers: [NearbyProvider] = []
    private(set) var isLoadingMore = false
    private(set) var loadMoreFailed = false
    private(set) var isSearching  = false
    private var unfilteredSnapshot: (providers: [NearbyProvider], page: NearbyProvidersPage)?
    
    var searchText = ""
    
    /// 最近加载的一页，用来知道下一页的页码、位置，以及还有没有更多
    private var lastPage: NearbyProvidersPage?
    
    private let fetchNearbyProviders: FetchNearbyProvidersUseCase
    
    init(fetchNearbyProviders: FetchNearbyProvidersUseCase) {
        self.fetchNearbyProviders = fetchNearbyProviders
    }
    
    var hasMore: Bool { lastPage?.hasMore ?? false }
    var locationSource: LocationSource? { lastPage?.locationSource }
    
    /// 首次加载和下拉刷新
    func load() async {
        Logger.providers.debug("load first page")
        unfilteredSnapshot = nil
        do {
            let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let page = try await fetchNearbyProviders.firstPage(keyword: keyword.isEmpty ? nil : keyword)
            providers = page.providers
            lastPage = page
            loadMoreFailed = false
            state = .loaded
        } catch {
            if Task.isCancelled { return }
            // 下拉刷新失败时，已经有数据就继续显示旧数据
            if providers.isEmpty {
                state = .fail(message(for: error))
            }
        }
    }
    
    // MARK: - 加载更多
    
    func loadMore() async {
        guard let current = lastPage, current.hasMore, !isLoadingMore else { return }
        
        Logger.providers.debug("load page \(current.page + 1)")
        
        isLoadingMore = true
        loadMoreFailed = false
        defer { isLoadingMore = false }
        
        do {
            let next = try await fetchNearbyProviders.page(
                current.page + 1,
                around: current.location,
                locationSource: current.locationSource,
                keyword: current.keyword
            )
            
            // 等待期间如果下拉刷新了，这一页已经过时，丢掉
            guard lastPage == current else { return }
            
            let existingIDs = Set(providers.map(\.id))
            providers += next.providers.filter { !existingIDs.contains($0.id) }
            lastPage = next
        } catch {
            if Task.isCancelled { return }
            loadMoreFailed = true
        }
    }
    
    func search() async {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let current = lastPage else { return }
        guard keyword != (current.keyword ?? "") else {
            // 搜索失败后又清空了搜索框：列表其实没有变化，从错误页回到列表
            if case .fail = state, !providers.isEmpty { state = .loaded }
            return
        }
        
        // 清空了搜索框，有快照就直接恢复，不用请求
        if keyword.isEmpty, let snapshot = unfilteredSnapshot {
            providers = snapshot.providers
            lastPage = snapshot.page
            unfilteredSnapshot = nil
            loadMoreFailed = false
            state = .loaded
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        do {
            let page = try await fetchNearbyProviders.page(
                1,
                around: current.location,
                locationSource: current.locationSource,
                keyword: keyword.isEmpty ? nil : keyword
            )
            // 等待期间用户又输入了，这次的结果已经过时
            guard !Task.isCancelled else { return }
            
            // 从完整列表进入搜索：替换列表之前，先保存一份快照
            if current.keyword == nil {
                unfilteredSnapshot = (providers, current)
            }
            
            providers = page.providers
            lastPage = page
            loadMoreFailed = false
            state = .loaded
        } catch {
            if Task.isCancelled { return }
            state = .fail(message(for: error))
        }
    }
    
    func retry() async {
        state = .loading
        await load()
    }
    
    /// 只在还没加载过时加载，切换 Tab 回来时不会重新请求
    func loadIfNeeded() async {
        guard case .loading = state else { return }
        await load()
    }
    
    var locationNotice: LocalizedStringResource? {
        switch locationSource {
        case .fallback(.denied):
            "Location access is off. Showing providers near the city centre."
        case .fallback(.unavailable):
            "Couldn't get your location. Showing providers near the city centre."
        case .current, nil:
            nil
        }
    }
    
    var canOpenSettings: Bool {
        locationSource == .fallback(.denied)
    }
    
    private func message(for error: Error) -> String {
        switch error as? ProviderError {
        case .network: String(localized: "Network connection failed. Please check your connection and try again.")
        case .sessionExpired: String(localized: "Your session has expired. Please sign in again.")
        case .notFound, .unknown, nil: String(localized: "Couldn't load providers. Please try again later.")
        }
    }
}
