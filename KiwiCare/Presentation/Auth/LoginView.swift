//
//  LoginView.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                BrandHeader()
                
                form
                
                PrimaryButton(title: "Log in", isLoading: viewModel.isLoading) {
                    Task {
                        await viewModel.submit()
                    }
                }
                .disabled(!viewModel.canSubmit)
                
                if let errorMessage = viewModel.errorMessage {
                    ErrorLabel(message: errorMessage)
                        .padding(.bottom, 24)
                }
            }
            .padding()
            .animation(.default, value: viewModel.errorMessage)
        }
        .defaultScrollAnchor(.center, for: .alignment)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var form: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Please login to continue.")
                .font(.title3)
                .bold()
            
            InputField(title: "Email",
                       placeholder: "请输入邮箱",
                       icon: "at",
                       contentType: .username,
                       keyboardType: .emailAddress,
                       text: $viewModel.email
            )
            
            InputField(title: "Password",
                       placeholder: "请输入密码",
                       icon: "key",
                       isSecure: true,
                       contentType: .password,
                       text: $viewModel.password)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}

#if DEBUG
private struct PreviewSignInUseCase: SignInUseCase {
    var error: AuthError?

    func execute(email: String, password: String) async throws -> AuthSession {
        try await Task.sleep(for: .seconds(1))
        if let error { throw error }
        return AuthSession(
            user: User(id: "1", name: "Preview", email: email,
                       phone: nil, avatarURL: nil, city: nil),
            role: .customer
        )
    }
}

private func previewLogin(error: AuthError? = nil) -> some View {
    NavigationStack {
        LoginView(viewModel: LoginViewModel(
            signIn: PreviewSignInUseCase(error: error),
            onSignedIn: { _ in }
        ))
    }
}

#Preview("Success - Light") {
    previewLogin()
}

#Preview("Success - Dark") {
    previewLogin()
        .preferredColorScheme(.dark)
}

#Preview("Wrong password") {
    previewLogin(error: .invalidCredentials)
}

#Preview("Offline") {
    previewLogin(error: .network)
}
#endif
