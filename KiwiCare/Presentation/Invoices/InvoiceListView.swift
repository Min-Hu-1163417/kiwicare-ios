//
//  InvoiceListView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import SwiftUI

struct InvoiceListView: View {
    @State private var viewModel: InvoiceListViewModel
    @State private var isCreating = false
    private let makeCreateInvoice: () -> CreateInvoiceViewModel
    
    init(viewModel: InvoiceListViewModel,
         makeCreateInvoice: @escaping () -> CreateInvoiceViewModel) {
        _viewModel = State(wrappedValue: viewModel)
        self.makeCreateInvoice = makeCreateInvoice
    }
    
    var body: some View {
        List(viewModel.invoices) { invoice in
            InvoiceRow(invoice: invoice)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("", systemImage: "plus") {
                    isCreating = true
                }
            }
        }
        .sheet(isPresented: $isCreating) {
            NavigationStack {
                CreateInvoiceView(viewModel: makeCreateInvoice())
            }
        }
        .overlay {
            if viewModel.invoices.isEmpty {
                ContentUnavailableView("No invoices yet",
                                       systemImage: "doc.text",
                                       description: Text("Invoices you create will appear here."))
            }
        }
        .navigationTitle("Invoices")
        .onAppear {
            viewModel.load()
        }
    }
    
    private struct InvoiceRow: View {
        let invoice: Invoice
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(invoice.description ?? "Invoice")
                        .font(.headline)
                    Text(invoice.createdAt, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(Decimal(invoice.amount) / 100, format: .currency(code: "NZD"))
                        .font(.headline.monospacedDigit())
                    SyncStatusBadge(status: invoice.syncStatus)
                }
            }
            .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                dimensions[.leading]
            }
        }
    }
    
    private struct SyncStatusBadge: View {
        let status: SyncStatus
        
        var body: some View {
            switch status {
            case .pending:
                Label("Waiting to upload", systemImage: "clock")
                    .foregroundStyle(.orange)
                    .labelIconToTitleSpacing(4)
            case .syncing:
                Label("Uploading", systemImage: "arrow.up.circle")
                    .foregroundStyle(.blue)
                    .labelIconToTitleSpacing(4)
            case .synced:
                Label("Uploaded", systemImage: "checkmark.circle")
                    .foregroundStyle(.green)
                    .labelIconToTitleSpacing(4)
            case .failed:
                Label("Upload failed", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .labelIconToTitleSpacing(4)
            }
        }
    }
}

#if DEBUG

#Preview("All statuses") {
    NavigationStack {
        InvoiceListView(viewModel: InvoiceListViewModel(useCase: PreviewFetchInvoices(), userID: "1"),
                        makeCreateInvoice: {
            CreateInvoiceViewModel(createInvoice: PreviewCreateInvoice(), onCreated: { _ in })
        })
    }
}

private func previewInvoiceListView() -> some View {
    NavigationStack {
        InvoiceListView(viewModel: InvoiceListViewModel(useCase: PreviewFetchInvoices(invoices: []), userID: "1"),
                        makeCreateInvoice: {
            CreateInvoiceViewModel(createInvoice: PreviewCreateInvoice(), onCreated: { _ in })
        }
        )
    }
}

#Preview("Empty - Light") {
    previewInvoiceListView()
}

#Preview("Empty - Dark") {
    previewInvoiceListView()
        .preferredColorScheme(.dark)
}

#endif
