//
//  CreateInvoiceView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

import PhotosUI
import SwiftUI

struct CreateInvoiceView: View {
    @State private var viewModel: CreateInvoiceViewModel
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isPickingPhotos = false
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
            
            Section {
                attachmentsRow
            } header: {
                Text("Photos")
            } footer: {
                if let hint = viewModel.attachmentHint {
                    Text(hint)
                }
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
        .photosPicker(
            isPresented: $isPickingPhotos,
            selection: $pickerItems,
            maxSelectionCount: viewModel.remainingAttachmentSlots,
            matching: .images
        )
        .onChange(of: pickerItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                let images = await Self.loadImageData(from: items)
                viewModel.addAttachments(images)
                pickerItems = []
            }
        }
        .onDisappear {
            viewModel.cancelUploads()
        }
    }
    
    // MARK: - Photos
    
    private var attachmentsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.attachments) { attachment in
                    AttachmentCell(
                        attachment: attachment,
                        onRetry: { viewModel.retryAttachment(id: attachment.id) },
                        onRemove: { viewModel.removeAttachment(id: attachment.id) }
                    )
                }
                
                if viewModel.remainingAttachmentSlots > 0 {
                    Button {
                        isPickingPhotos = true
                    } label: {
                        addPhotoTile
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var addPhotoTile: some View {
        VStack(spacing: 4) {
            Image(systemName: "camera.fill")
                .font(.title3)
            Text("Add")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .frame(width: AttachmentCell.size, height: AttachmentCell.size)
        .background(.quaternary, in: .rect(cornerRadius: 10))
    }
    
    /// 同时读取多张选中的图片，结果保持选择时的顺序
    private static func loadImageData(from items: [PhotosPickerItem]) async -> [Data] {
        await withTaskGroup(of: (Int, Data?).self) { group in
            for (index, item) in items.enumerated() {
                group.addTask {
                    (index, try? await item.loadTransferable(type: Data.self))
                }
            }
            
            var results = [Data?](repeating: nil, count: items.count)
            for await (index, data) in group {
                results[index] = data
            }
            return results.compactMap { $0 }
        }
    }
}
