//
//  TokenStore.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

protocol TokenStore: AnyObject {
    var token: String? { get }
    func save(_ token: String)
    func clear()
}
