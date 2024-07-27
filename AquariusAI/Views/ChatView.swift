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
    @State private var chats: [Chat] = []
    @State private var messages: [Message] = []
    @State private var selectedChat: Chat?
    @State private var showConfirmView = false
    @State private var endpoint: Endpoint?
    @State private var agent: Agent?
    @State private var prompt: String = ""
    @FocusState private var isFocused: Bool
    @State private var isChatting = false
    @State private var chattingMessage = ""
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                sidebar()
                Spacer()
                Divider()
                ModelPicker(endpoint: $endpoint, modelFamily: .ollama)
                    .padding(.top, 8)
                
                AgentPicker(agent: $agent)
                    .padding(.top, 8)
            }
            .padding()
            .navigationSplitViewColumnWidth(300)
        } detail: {
            if let chat = selectedChat {
                VStack {
                    chatArea(chat: chat)
                    chatInputArea()
                }
            } else {
                ContentUnavailableView {
                    Text("How are you today?")
                }
            }
        }
        .onDisappear {
            print("onDisappear")
        }
    }
    
    private func sidebar() -> some View {
        VStack {
            List(chats, selection: $selectedChat) { chat in
                Label(chat.name, systemImage: "bubble")
                    .tag(chat)
            }
            .alert(Text("Are you sure you want to delete the chat?"), isPresented: $showConfirmView) {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
            .onChange(of: selectedChat) {
                if let chat = selectedChat {
                    onMessageFetch(chat: chat)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Spacer()
                Button("New Chat", systemImage: "square.and.pencil") {
                    onAdd()
                }
            }
        }
        .task {
            await onFetch()
        }
    }
    
    private func chatArea(chat: Chat) -> some View {
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
        .navigationTitle(chat.name)
        .navigationSubtitle("\(endpoint?.name ?? ""):\(agent?.name ?? "")")
        .toolbar {
            ToolbarItemGroup {
                Button("Edit", systemImage: "pencil.line") {

                }
                Button("Delete", systemImage: "trash") {

                }
            }
        }
        .onChange(of: selectedChat) {

        }
    }
    
    private func chatInputArea() -> some View {
        VStack {
            HStack {
                TextField("Enter Your Message", text: $prompt, axis: .vertical)
                    .font(.system(size: 14))
                    .opacity(0)
                    .lineLimit(1...8)
                    .padding(.horizontal, 8)
                    .overlay {
                        ZStack {
                            TextEditor(text: $prompt)
                                .font(.system(size: 14))
                                .scrollIndicators(.never)
                                .padding(.horizontal, 8)
                                .focused($isFocused)
                                .onAppear() {
                                    keyboardSubscribe()
                                }

                            if prompt.isEmpty {
                                Text(" Enter Your Message")
                                    .foregroundStyle(.tertiary)
                                    .padding(.leading, 8)
                                    .leftAligned()
                                    .topAligned()
                            }
                        }
                    }
                VStack {
                    if !isChatting {
                        Button(action: onSend) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: onStop) {
                            Image(systemName: "stop.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()
                .frame(height: 8)
        }
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
    private func onFetch() async {
        do {
            chats = try await ChatService.shared.fetch()
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
        }
        if !chats.isEmpty {
            selectedChat = chats.first
        }
    }
    
    private func onAdd() {
        let chat = Chat(name: "new chat")
        ChatService.shared.addChat(chat)
        chats = ChatService.shared.fetchCache()
        selectedChat = chat
    }
    
    private func onDelete() {

    }
    
    private func onMessageFetch(chat: Chat) {
        messages = ChatService.shared.fetchMessageCache(chat)
    }
    
    private func onSend() {
        if prompt.isEmpty {
            return
        }
        guard let chat = selectedChat else {
            errorBinding.appError = AppError.missingChat
            return
        }
        guard let endpoint = endpoint  else {
            errorBinding.appError = AppError.missingModel
            return
        }
        guard let agent = agent  else {
            errorBinding.appError = AppError.missingAgentModel
            return
        }
        isChatting = true
        chattingMessage = ""
        let userMessage = Message(chatId: chat.id, content: prompt, sequence: 0, role: Role.user)
        ChatService.shared.addMessage(userMessage, chat: chat)
        messages.append(userMessage)
        Task {
            try await OllamaService.shared.callCompletionApi(messages: messages, endpoint: endpoint, agent: agent) { response in
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
    func keyboardSubscribe() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
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
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Schema([Chat.self, Message.self, Endpoint.self, Agent.self]), configurations: config)
    let chat1 = Chat(name: "new chat1")
    let chat2 = Chat(name: "new chat2")
    container.mainContext.insert(chat1)
    container.mainContext.insert(chat2)
    container.mainContext.insert(Message(chatId: chat1.id, content: "hi", sequence: 0, role: Role.user))
    container.mainContext.insert(Message(chatId: chat1.id, content: "Hello! How can I help you today? If you have any questions or need assistance, feel free to ask.", sequence: 1, role: Role.assistant))
    container.mainContext.insert(Message(chatId: chat1.id, content: "Thank you!", sequence:2, role: Role.user))
    var endpoint = Endpoint(name: "qwen7b", modelFamily: .ollama)
    endpoint.endpoint = "qwen2:1.5b-instruct-q5_K_M"
    container.mainContext.insert(endpoint)
    container.mainContext.insert(Agent(name: "Aquarius"))
    EndpointService.shared.configure(with: container.mainContext)
    AgentService.shared.configure(with: container.mainContext)
    ChatService.shared.configure(with: container.mainContext)

    return ChatView()
        .environment(ErrorBinding())
}
