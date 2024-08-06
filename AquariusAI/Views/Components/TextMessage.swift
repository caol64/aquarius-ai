//
//  TextMessage.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/4/28.
//

import SwiftUI
import SwiftData
import MarkdownUI

struct TextMessage: View {
    
    let message: Message
    @State private var isCopied = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Markdown(message.content)
                    .textSelection(.enabled)
                    .padding()
            }
            .background(message.isAssistant() ? .clear : .accentColor)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: message.isAssistant() ? .leading : .trailing)
            
            if message.isAssistant() {
                HStack(spacing: 8) {
                    Button(action: onCopy) {
                        Image(systemName: isCopied ? "checkmark" : "clipboard")
                    }
                    .buttonStyle(.accessoryBar)
                    .clipShape(.circle)
                    .help("Copy")
                    //                .visible(if: isCopyButtonVisible)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.accessoryBar)
                    .clipShape(.circle)
                    .help("Delete")
                    //                .visible(if: isRegenerateButtonVisible)
                }
                .padding(.top, 8)
                .leftAligned()
                
                Divider()
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Actions
    private func onDelete() {
        
    }
    
    private func onCopy() {
        let content = MarkdownContent(message.content)
        let plainText = content.renderPlainText()
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(plainText, forType: .string)
        
        isCopied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isCopied = false
        }
    }
}

// MARK: - Preview
#Preview {
    let message = Message(chatId: "0", content: "hi", sequence: 0, role: Role.user)
//    let message = Message(chatId: "0", content: "Hello! How can I help you today? If you have any questions or need assistance, feel free to ask.", sequence: 0, role: Role.assistant)
    
    return TextMessage(message: message)
}
