//
//  MainTabView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import SwiftUI

struct MainTabView: View {
    let session: AuthSession
    let onSignOut: () -> Void
    let makeInvoiceList: () -> InvoiceListViewModel
    let makeCreateInvoice: () -> CreateInvoiceViewModel
    
    var body: some View {
        TabView {
            Tab("Invoices", systemImage: "doc.text") {
                NavigationStack {
                    InvoiceListView(viewModel: makeInvoiceList(), makeCreateInvoice: makeCreateInvoice)
                }
            }
            
            Tab("Profile", systemImage: "person.crop.circle") {
                NavigationStack {
                    ProfileView(session: session, onSignOut: onSignOut)
                }
            }
        }
    }
}

#if DEBUG

private func makeMainTabPreview() -> some View {
    MainTabView(
        session: .preview,
        onSignOut: {},
        makeInvoiceList: {
            InvoiceListViewModel(useCase: PreviewFetchInvoices(), userID: "1")
        },
        makeCreateInvoice: {
            CreateInvoiceViewModel(createInvoice: PreviewCreateInvoice(), onCreated: { _ in })
        }
    )
}

#Preview("Light") { makeMainTabPreview() }
#Preview("Dark") { makeMainTabPreview().preferredColorScheme(.dark) }

#endif
