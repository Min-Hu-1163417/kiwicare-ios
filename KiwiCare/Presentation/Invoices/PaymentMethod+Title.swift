//
//  PaymentMethod+Title.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import Foundation

extension PaymentMethod {
    var title: String {
        switch self {
        case .cash: String(localized: "Cash", comment: "Payment method")
        case .creditCard: String(localized: "Credit card", comment: "Payment method")
        case .bankTransfer: String(localized: "Bank transfer", comment: "Payment method")
        case .other: String(localized: "Other", comment: "Payment method")
        }
    }
}
