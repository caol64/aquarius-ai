//
//  ChatView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/2.
//

import SwiftUI
import SwiftData
import MarkdownUI

struct ChatView: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var messages: [Message] = []
    @State private var chat: Chat = Chat(name: "New Chat")
    @State private var selectedEndpoint: Endpoint?
    @State private var showConfirmView = false
    @State private var prompt: String = ""
    @State private var isChatting = false
    @State private var chattingMessage = ""
    @State private var showEndpointPicker = false
    @State private var config: OllamaConfig = OllamaConfig()
    @State private var systemPrompt: String = OllamaConfig.defaultSystemPrompt
    @FocusState private var isFocused: Bool
    @State private var keyDownMonitor: Any?
    private var modelFamily: ModelFamily = .ollama
    private let title = "Text Generation"
    
    var body: some View {
        NavigationSplitView {
            VStack {
                Label("Agent Options", systemImage: "gearshape.2.fill")
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .leftAligned()
                ScrollView {
                    Text("Role")
                        .leftAligned()
                    TextEditor(text: $systemPrompt)
                        .padding(.top, 4)
                        .frame(height: 80)
                        .font(.body)
                    GenerationParameterGroup(config: $config)
                        .padding(.trailing, 16)
                }
            }
            .topAligned()
            .padding(.leading, 16)
            .navigationSplitViewColumnWidth(300)
        } detail: {
            VStack(spacing: 0) {
                chatArea()
                chatInputArea()
            }
            .navigationSplitViewColumnWidth(min: 750, ideal: 750, max: .infinity)
        }
        .onTapGesture {
            if showEndpointPicker {
                showEndpointPicker = false
            }
        }
        .onDisappear {
            removeKeyboardSubscribe()
        }
        .task {
            onMessageFetch(chat: chat)
        }
        .frame(minHeight: 580)
    }
    
    private func chatArea() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(messages, id: \.self.id) { message in
                    TextMessage(message: message)
                }
                
                if isChatting {
                    chattingArea()
                }
            }
            .padding()
            
        }
        .background(.white)
        .navigationTitle("")
        .toolbar {
            EndpointToolbar(endpoint: $selectedEndpoint, showEndpointPicker: $showEndpointPicker, title: title, modelFamily: modelFamily)
            ToolbarItemGroup {
                Button("Edit", systemImage: "pencil.line") {
                    
                }
                Button("Delete", systemImage: "trash") {
                    
                }
            }
        }
        .overlay(alignment: .top) {
            if showEndpointPicker {
                EndpointsList(endpoint: $selectedEndpoint, modelFamily: modelFamily)
            }
        }
    }
    
    private func chatInputArea() -> some View {
        VStack(spacing: 0)  {
            HStack {
                TextField("", text: $prompt, axis: .vertical)
                    .font(.system(size: 14))
                    .opacity(0)
                    .lineLimit(1...8)
                    .overlay {
                        ZStack {
                            TextEditor(text: $prompt)
                                .font(.system(size: 14))
                                .scrollIndicators(.never)
                                .focused($isFocused)
                                .onChange(of: isFocused) {
                                    if isFocused {
                                        keyboardSubscribe()
                                    } else {
                                        removeKeyboardSubscribe()
                                    }
                                }
                            if prompt.isEmpty {
                                Text("Enter Your Message")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.tertiary)
                                    .padding(.leading, 8)
                                    .leftAligned()
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                VStack {
                    if !isChatting {
                        Button(action: onSend) {
                            Image(systemName: "paperplane.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(.circle)
                    } else {
                        Button(action: onStop) {
                            Image(systemName: "stop.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(.circle)
                        .tint(.red)
                    }
                }
            }
            
        }
        .padding(8)
    }
    
    private func chattingArea() -> some View {
        VStack(spacing: 8) {
            Markdown(chattingMessage)
                .padding()
        }
        .padding(.vertical)
        .cornerRadius(10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Actions
    private func onMessageFetch(chat: Chat) {
        messages = ChatService.shared.fetchMessageCache(chat)
    }
    
    private func onSend() {
        if prompt.isEmpty {
            return
        }
        guard let endpoint = selectedEndpoint  else {
            errorBinding.appError = AppError.missingModel
            return
        }
        isChatting = true
        chattingMessage = ""
        let userMessage = Message(chatId: chat.id, content: prompt, sequence: 0, role: Role.user)
        ChatService.shared.addMessage(userMessage, chat: chat)
        messages.append(userMessage)
        Task {
            try await OllamaService.shared.callCompletionApi(messages: messages, systemPrompt: systemPrompt, endpoint: endpoint, config: config) { response in
                self.chattingMessage += (response.message?.content ?? "")
            } onComplete: { data in
                isChatting = false
                let assistantMessage = Message(chatId: chat.id, content: self.chattingMessage, sequence: 0, role: Role.assistant)
                ChatService.shared.addMessage(assistantMessage, chat: chat)
                messages.append(assistantMessage)
                chattingMessage = ""
            } onError: { error in
                print(error)
                errorBinding.appError = AppError.unexpected(description: error.localizedDescription)
            }
        }
    }
    
    private func onStop() {
        
    }
    
    // MARK: - keyboardSubscribe
    private func keyboardSubscribe() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            /// shift + enter, see https://gist.github.com/swillits/df648e87016772c7f7e5dbed2b345066
            if aEvent.modifierFlags.contains(.shift) && aEvent.keyCode == 0x24 {
                prompt += "\n"
                return nil
            } else if aEvent.keyCode == 0x24 {
                onSend()
                return nil
            }
            return aEvent
        }
    }
    
    private func removeKeyboardSubscribe() {
        if let monitor = keyDownMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Schema([Endpoint.self]), configurations: config)
    let chat = Chat(name: "new chat")
    ChatService.shared.addMessage(Message(chatId: chat.id, content: "hi", sequence: 0, role: Role.user), chat: chat)
    ChatService.shared.addMessage(Message(chatId: chat.id, content: "Hello! How can I help you today? If you have any questions or need assistance, feel free to ask.", sequence: 1, role: Role.assistant), chat: chat)
    ChatService.shared.addMessage(Message(chatId: chat.id, content: "Thank you!", sequence:2, role: Role.user), chat: chat)
    var endpoint = Endpoint(name: "qwen7b", modelFamily: .ollama)
    endpoint.endpoint = "qwen2:1.5b-instruct-q5_K_M"
    container.mainContext.insert(endpoint)
    let errorBinding = ErrorBinding()
    EndpointViewModel.shared.configure(modelContext: container.mainContext, errorBinding: errorBinding)
    
    return ChatView()
        .environment(errorBinding)
}
