//
//  FetchProviderDetailUseCase.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

import Foundation

protocol FetchProviderDetailUseCase {
    func execute(id: UUID) async throws -> Provider
}

final class DefaultFetchProviderDetailUseCase: FetchProviderDetailUseCase {
    let repository: ProviderRepository
    
    init(repository: ProviderRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID) async throws -> Provider {
        try await repository.provider(id: id)
    }
}
