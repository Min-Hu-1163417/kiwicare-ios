//
//  ProfileView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    let onSignOut: () -> Void
    
    init(viewModel: ProfileViewModel, onSignOut: @escaping () -> Void) {
        _viewModel = State(wrappedValue: viewModel)
        self.onSignOut = onSignOut
    }
    
    var body: some View {
        content
            .task {
                await viewModel.load()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let user, let stats):
            List {
                Section {
                    VStack(spacing: 8) {
                        AvatarView(url: user.avatarURL, size: 88)
                        Text(user.name)
                            .font(.title2.bold())
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                
                Section("Account") {
                    LabeledContent("Name", value: user.name)
                    LabeledContent("Email", value: user.email)
                }
                
                Section("Invoices") {
                    LabeledContent("Total", value: "\(stats.count)")
                    LabeledContent("Amount") {
                        Text(Decimal(stats.totalAmount) / 100, format: .currency(code: "NZD"))
                    }
                    LabeledContent("Waiting to sync", value: "\(stats.pendingCount)")
                }
                
                Section {
                    Button(role: .destructive, action: onSignOut) {
                        Text("Log out")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .refreshable { await viewModel.load() }
        case .failed(let error):
            ContentUnavailableView {
                Label("Couldn't load profile", systemImage: "person.crop.circle.badge.exclamationmark")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") {
                    Task {
                        await viewModel.load()
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Sign out", role: .destructive, action: onSignOut)
            }
        }
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        ProfileView(
            viewModel: ProfileViewModel(
                restoreSession: PreviewRestoreSession(),
                fetchInvoiceStats: PreviewFetchInvoiceStats(),
                userID: "1"
            ),
            onSignOut: {}
        )
    }
}

#endif
