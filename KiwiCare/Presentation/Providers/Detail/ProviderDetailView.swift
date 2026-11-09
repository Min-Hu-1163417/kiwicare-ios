//
//  ProviderDetailView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 09/11/2026.
//

import SwiftUI

struct ProviderDetailView: UIViewControllerRepresentable {
    let makeViewController: () -> ProviderDetailViewController
    let onCreateInvoice: (NearbyProvider) -> Void

    func makeUIViewController(context: Context) -> ProviderDetailViewController {
        let viewController = makeViewController()
        viewController.onCreateInvoice = onCreateInvoice
        return viewController
    }
    
    func updateUIViewController(_ viewController: ProviderDetailViewController, context: Context) {
        viewController.onCreateInvoice = onCreateInvoice
    }
}
