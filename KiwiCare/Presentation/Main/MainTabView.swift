//
//  MainTabView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import SwiftUI

struct MainTabView: View {
    let onSignOut: () -> Void
    
    @Environment(\.screenFactory) private var screenFactory
    
    var body: some View {
        TabView {
            Tab("Invoices", systemImage: "doc.text") {
                NavigationStack {
                    InvoiceListView(viewModel: screenFactory.invoiceList())
                }
            }
            
            Tab("Nearby", systemImage: "mappin.and.ellipse") {
                NavigationStack {
                    NearbyProvidersView(viewModel: screenFactory.nearbyProviders())
                }
            }
            
            Tab("Profile", systemImage: "person.crop.circle") {
                NavigationStack {
                    ProfileView(viewModel: screenFactory.profile(), onSignOut: onSignOut)
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    MainTabView(onSignOut: {})
        .environment(\.screenFactory, .preview)
}

#endif
