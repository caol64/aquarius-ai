//
//  ChatViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation
import AppKit.NSEvent

@Observable
class ChatViewModel: BaseViewModel {
    var messages: [Messages] = []
    var chat: Chats = Chats(name: "New Chat")
    var selectedModel: Models?
    var showConfirmView = false
    var prompt: String = ""
    var isChatting = false
    var chattingMessage = ""
    var showModelPicker = false
    var config: OllamaConfig = OllamaConfig()
    var expandId: String?
    var systemPrompt: String = "You are Aquarius, a helpful assistant."
    var keyDownMonitor: Any?
    
    func closeModelListPopup() {
        showModelPicker = false
    }
    
    func removeKeyboardSubscribe() {
        if let monitor = keyDownMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    func keyboardSubscribe() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            // shift + enter, see https://gist.github.com/swillits/df648e87016772c7f7e5dbed2b345066
            if aEvent.modifierFlags.contains(.shift) && aEvent.keyCode == 0x24 {
                self.prompt += "\n"
                return nil
            } else if aEvent.keyCode == 0x24 {
                self.onSend()
                return nil
            }
            return aEvent
        }
    }
    
    func onSend() {
        if prompt.isEmpty {
            return
        }
        guard let model = selectedModel else {
            handleError(error: AppError.missingModel)
            return
        }
        isChatting = true
        chattingMessage = ""
        let userMessage = Messages(chatId: chat.id, content: prompt, sequence: 0, role: Role.user)
        ChatService.shared.addMessage(userMessage, chat: chat)
        messages.append(userMessage)
        Task {
            try await OllamaService.shared.callCompletionApi(messages: messages, systemPrompt: systemPrompt, model: model, config: config) { response in
                self.chattingMessage += (response.message?.content ?? "")
            } onComplete: { data in
                self.isChatting = false
                let assistantMessage = Messages(chatId: self.chat.id, content: self.chattingMessage, sequence: 0, role: Role.assistant)
                ChatService.shared.addMessage(assistantMessage, chat: self.chat)
                self.messages.append(assistantMessage)
                self.chattingMessage = ""
            } onError: { error in
                self.handleError(error: error)
            }
        }
    }
    
    func onStop() {
        
    }
    
    func onFocusChange(isFocused: Bool) {
        if isFocused {
            keyboardSubscribe()
        } else {
            removeKeyboardSubscribe()
        }
    }
}
