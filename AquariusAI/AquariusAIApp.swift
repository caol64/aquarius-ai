//
//  AquariusAIApp.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/4/23.
//

import SwiftUI
import SwiftData

@main
struct AquariusAIApp: App {
    @State private var appState: AppState
    private var modelViewModel: ModelViewModel
    private var knowledgeViewModel: KnowledgeViewModel
    private var pluginViewModel: PluginViewModel
    @State private var textGenerationViewModel: TextGenerationViewModel
    @State private var chatViewModel: ChatViewModel
    @State private var imageViewModel: ImageViewModel

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Models.self,
            Plugins.self,
            Knowledges.self,
            KnowledgeChunks.self,
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        let modelContext = sharedModelContainer.mainContext
        let appState = AppState()
        _appState = State(initialValue: appState)
        modelViewModel = ModelViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
        knowledgeViewModel = KnowledgeViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
        pluginViewModel = PluginViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
        textGenerationViewModel = TextGenerationViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
        chatViewModel = ChatViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
        imageViewModel = ImageViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
    }

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("Aquarius AI", systemImage: "hammer") {
            AppMenu()
        }

        Settings {
            SettingsView()
                .environment(modelViewModel)
                .environment(knowledgeViewModel)
                .environment(pluginViewModel)
                .alert(isPresented: appState.showSettingsError, error: appState.errorBinding.appError) {}
        }
        #endif
        
        WindowGroup(id: Page.text.rawValue) {
            TextGenerationView(viewModel: textGenerationViewModel)
                .environment(modelViewModel)
                .environment(knowledgeViewModel)
                .environment(pluginViewModel)
                .alert(isPresented: appState.showTextError, error: appState.errorBinding.appError) {}
        }
        
        WindowGroup(id: Page.chat.rawValue) {
            ChatView(viewModel: chatViewModel)
                .environment(modelViewModel)
                .environment(knowledgeViewModel)
                .environment(pluginViewModel)
                .alert(isPresented: appState.showChatError, error: appState.errorBinding.appError) {}
        }
        
        WindowGroup(id: Page.image.rawValue) {
            ImageGenerationView(viewModel: imageViewModel)
                .environment(modelViewModel)
                .environment(pluginViewModel)
                .alert(isPresented: appState.showImageError, error: appState.errorBinding.appError) {}
        }
    }
}
