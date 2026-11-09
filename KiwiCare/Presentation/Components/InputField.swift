//
//  Untitled.swift
//  KiwiCare
//
//  Created by Vincent Hu on 05/11/2026.
//

import SwiftUI

struct InputField: View {
    let title: LocalizedStringKey
    let placeholder: String
    let icon: String
    var isSecure = false
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
            
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
                .textContentType(contentType)
                .focused($isFocused)
                
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: Theme.controlHeight)
            .background(Color(.systemBackground))
            .clipShape(.rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(isFocused ? Color.accentColor : Color(.separator), lineWidth: 1)
            }
            .contentShape(.rect)
            .onTapGesture {
                isFocused = true
            }
        }
    }
}

