//
//  KeychainTokenStore.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

final class KeychainTokenStore: TokenStore {
    private static let key = "authToken"
    private(set) var token: String?

    init() {
        token = Keychain.read(Self.key)
    }

    func save(_ token: String) {
        Keychain.save(token, for: Self.key)
        self.token = token
    }

    func clear() {
        Keychain.delete(Self.key)
        token = nil
    }
}
