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
    @State private var appState: AppState = .init()
    @State private var modelViewModel: ModelViewModel
    @State private var knowledgeViewModel: KnowledgeViewModel
    @State private var textGenerationViewModel: TextGenerationViewModel = .init()
    @State private var imageGenerationViewModel: ImageGenerationViewModel = .init()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Mlmodel.self,
            Knowledge.self,
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
        let dataRepository = DataRepository(modelContext: modelContext)
        modelViewModel = ModelViewModel(dataRepository: dataRepository)
        knowledgeViewModel = KnowledgeViewModel(dataRepository: dataRepository)
    }
    
    var body: some Scene {
#if os(macOS)
        MenuBarExtra("Aquarius AI", image: "MenubarIcon") {
            AppMenu()
                .environment(appState)
        }
        
        Settings {
            SettingsView()
                .environment(appState)
                .environment(modelViewModel)
                .environment(knowledgeViewModel)
                .alert(isPresented: appState.showSettingsError, error: appState.error) {}
        }
#endif
        
        WindowGroup(id: Page.text.rawValue) {
            TextGenerationView()
                .environment(appState)
                .environment(textGenerationViewModel)
                .environment(modelViewModel)
                .environment(knowledgeViewModel)
                .alert(isPresented: appState.showTextError, error: appState.error) {}
        }
        
        WindowGroup(id: Page.image.rawValue) {
            ImageGenerationView()
                .environment(appState)
                .environment(imageGenerationViewModel)
                .environment(modelViewModel)
                .alert(isPresented: appState.showImageError, error: appState.error) {}
        }
    }
}
