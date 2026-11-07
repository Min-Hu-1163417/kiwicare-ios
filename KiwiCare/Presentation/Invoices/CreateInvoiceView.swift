//
//  CreateInvoiceView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import SwiftUI

struct CreateInvoiceView: View {
    @State private var viewModel: CreateInvoiceViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: CreateInvoiceViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section("Amount") {
                TextField("0.00", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .font(.title2.monospacedDigit())
            }
            
            Section("Payment method") {
                Picker("Payment method", selection: $viewModel.paymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.title)
                            .tag(method)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section("Description") {
                TextField("Optional", text: $viewModel.note, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    ErrorLabel(message: errorMessage)
                }
            }
        }
        .navigationTitle("New Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if viewModel.save() {
                        dismiss()
                    }
                }
                .disabled(!viewModel.canSave)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
    }
}
