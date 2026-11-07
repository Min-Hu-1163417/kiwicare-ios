//
//  PaymentMethod+Title.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

extension PaymentMethod {
    var title: String {
        switch self {
        case .cash: "Cash"
        case .creditCard: "Credit card"
        case .bankTransfer: "Bank transfer"
        case .other: "Other"
        }
    }
}
