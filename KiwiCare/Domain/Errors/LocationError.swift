//
//  LocationError.swift
//  KiwiCare
//
//  Created by Vincent Hu on 08/11/2026.
//

nonisolated enum LocationError: Error, Equatable {
    case denied       // 用户拒绝了权限
    case unavailable  // 有权限，但定位失败
}
