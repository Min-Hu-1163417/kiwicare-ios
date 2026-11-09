//
//  ProfileViewModel.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Observation
import Foundation

@Observable
final class ProfileViewModel {
    enum State: Equatable {
        case loading
        case loaded(user: User, stats: InvoiceStats)
        case failed(String)
    }
    
    private(set) var state: State = .loading
    
    private let restoreSession: RestoreSessionUseCase
    private let fetchInvoiceStats: FetchInvoiceStatsUseCase
    private let userID: String
    
    init(restoreSession: RestoreSessionUseCase, fetchInvoiceStats: FetchInvoiceStatsUseCase, userID: String) {
        self.restoreSession = restoreSession
        self.fetchInvoiceStats = fetchInvoiceStats
        self.userID = userID
    }
    
    func load() async {
        do {
            async let session = restoreSession.execute()
            async let stats = fetchInvoiceStats.execute(userID: userID)
            let (loadedSession, loadedStats) = try await (session, stats)
            
            guard let user = loadedSession?.user else {
                state = .failed(String(localized: "Please sign in again."))
                return
            }
            state = .loaded(user: user, stats: loadedStats)
        } catch {
            if Task.isCancelled {
                return
            }
            state = .failed(String(localized: "Couldn't load your profile."))
        }
    }
}
