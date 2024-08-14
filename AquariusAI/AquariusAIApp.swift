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
    @State private var modelViewModel: ModelViewModel
    @State private var knowledgeViewModel: KnowledgeViewModel
    @State private var textGenerationViewModel: TextGenerationViewModel
    @State private var imageViewModel: ImageViewModel

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Models.self,
            Knowledges.self,
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
        textGenerationViewModel = TextGenerationViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
        imageViewModel = ImageViewModel(errorBinding: appState.errorBinding, modelContext: modelContext)
    }

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("Aquarius AI", systemImage: "hammer") {
            AppMenu()
        }

        Settings {
            SettingsView()
                .environment(appState)
                .environment(modelViewModel)
                .environment(knowledgeViewModel)
                .alert(isPresented: appState.showSettingsError, error: appState.errorBinding.appError) {}
        }
        #endif
        
        WindowGroup(id: Page.text.rawValue) {
            TextGenerationView(viewModel: textGenerationViewModel)
                .environment(appState)
                .environment(modelViewModel)
                .environment(knowledgeViewModel)
                .alert(isPresented: appState.showTextError, error: appState.errorBinding.appError) {}
        }
        
        WindowGroup(id: Page.image.rawValue) {
            ImageGenerationView(viewModel: imageViewModel)
                .environment(appState)
                .environment(modelViewModel)
                .alert(isPresented: appState.showImageError, error: appState.errorBinding.appError) {}
        }
    }
}
