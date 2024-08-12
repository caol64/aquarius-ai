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
    @Bindable var viewModel: ChatViewModel
    @FocusState private var isFocused: Bool
    private var modelFamily: ModelFamily = .ollama
    private let title = "Chat"
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationSplitView {
            sidebar
                .topAligned()
                .padding(.leading, 16)
                .navigationSplitViewColumnWidth(300)
        } detail: {
            contentView
                .navigationSplitViewColumnWidth(min: 750, ideal: 750, max: .infinity)
        }
        .onTapGesture {
            viewModel.closeModelListPopup()
        }
        .onDisappear {
            viewModel.removeKeyboardSubscribe()
        }
        .frame(minHeight: 580)
    }
    
    // MARK: - sidebar
    @ViewBuilder
    private var sidebar: some View {
        generationOptions()
        ScrollView {
            Text("Role")
                .leftAligned()
            TextEditor(text: $viewModel.systemPrompt)
                .padding(.top, 4)
                .frame(height: 80)
                .font(.body)
            GenerationParameterGroup(expandId: $viewModel.expandId, config: $viewModel.config)
                .padding(.trailing, 16)
        }
    }
    
    // MARK: - contentView
    @MainActor
    private var contentView: some View {
        VStack {
            chatArea
            chatInputArea
        }
        .navigationTitle("")
        .toolbar {
            ModelPickerToolbar(model: $viewModel.selectedModel, showModelPicker: $viewModel.showModelPicker, title: title, modelFamily: modelFamily)
            ToolbarItemGroup {
                Button("Edit", systemImage: "pencil.line") {
                    
                }
                Button("Delete", systemImage: "trash") {
                    
                }
            }
        }
        .overlay(alignment: .top) {
            if viewModel.showModelPicker {
                ModelListPopup(model: $viewModel.selectedModel, modelFamily: modelFamily)
            }
        }
    }
    
    // MARK: - chatArea
    @MainActor
    private var chatArea: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.messages, id: \.self.id) { message in
                    TextMessage(message: message)
                }
                
                if viewModel.isChatting {
                    streamingArea
                }
            }
            .padding()
        }
        .background(.white)
        
    }
    
    // MARK: - chatInputArea
    @MainActor
    private var chatInputArea: some View {
        VStack(spacing: 0)  {
            HStack {
                TextField("", text: $viewModel.prompt, axis: .vertical)
                    .font(.system(size: 14))
                    .opacity(0)
                    .lineLimit(1...8)
                    .overlay {
                        ZStack {
                            TextEditor(text: $viewModel.prompt)
                                .font(.system(size: 14))
                                .scrollIndicators(.never)
                                .focused($isFocused)
                                .onChange(of: isFocused) {
                                    viewModel.onFocusChange(isFocused: isFocused)
                                }
                            if viewModel.prompt.isEmpty {
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
                    if !viewModel.isChatting {
                        Button(action: viewModel.onSend) {
                            Image(systemName: "paperplane.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(.circle)
                    } else {
                        Button(action: viewModel.onStop) {
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
    
    // MARK: - streamingArea
    @MainActor
    private var streamingArea: some View {
        VStack(spacing: 8) {
            Markdown(viewModel.chattingMessage)
                .padding()
        }
        .padding(.vertical)
        .cornerRadius(10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Schema([Models.self]), configurations: config)
    let chat = Chats(name: "new chat")
    ChatService.shared.addMessage(Messages(chatId: chat.id, content: "hi", sequence: 0, role: Role.user), chat: chat)
    ChatService.shared.addMessage(Messages(chatId: chat.id, content: "Hello! How can I help you today? If you have any questions or need assistance, feel free to ask.", sequence: 1, role: Role.assistant), chat: chat)
    ChatService.shared.addMessage(Messages(chatId: chat.id, content: "Thank you!", sequence:2, role: Role.user), chat: chat)
    var model = Models(name: "qwen7b", modelFamily: .ollama)
    model.endpoint = "qwen2:1.5b-instruct-q5_K_M"
    container.mainContext.insert(model)
    let appState = AppState()
    let modelViewModel = ModelViewModel(errorBinding: appState.errorBinding, modelContext: container.mainContext)
    let knowledgeViewModel = KnowledgeViewModel(errorBinding: appState.errorBinding, modelContext: container.mainContext)
    let pluginViewModel = PluginViewModel(errorBinding: appState.errorBinding, modelContext: container.mainContext)
    @State var viewModel = ChatViewModel(errorBinding: appState.errorBinding, modelContext: container.mainContext)
    
    return ChatView(viewModel: viewModel)
        .environment(modelViewModel)
        .environment(knowledgeViewModel)
        .environment(pluginViewModel)
        .environment(viewModel)
}
