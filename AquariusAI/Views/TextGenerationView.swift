//
//  TextGenerationView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI
import SwiftData
import MarkdownUI

struct TextGenerationView: View {
    @Bindable var viewModel: TextGenerationViewModel
    let title = "Text Generation"

    var body: some View {
        NavigationSplitView {
            sidebar
                .topAligned()
                .padding(.leading, 16)
                .navigationSplitViewColumnWidth(300)
        } detail: {
            contentView
                .navigationSplitViewColumnWidth(min: 750, ideal: 750, max: .infinity)
                .navigationTitle("")
                .toolbar {
                    ModelPickerToolbar(model: $viewModel.selectedModel, showModelPicker: $viewModel.showModelPicker, title: title, modelType: .llm)
                    ToolbarItemGroup {
                        Button("Copy", systemImage: "clipboard") {
                            
                        }
                    }
                }
                .overlay(alignment: .top) {
                    if viewModel.showModelPicker {
                        ModelListPopup(model: $viewModel.selectedModel, modelType: .llm)
                    }
                }
        }
        .onTapGesture {
            viewModel.closeModelListPopup()
        }
        .frame(minHeight: 580)
    }
    
    // MARK: - sidebar
    @ViewBuilder
    @MainActor
    private var sidebar: some View {
        generationOptions()
        ScrollView {
            prompts
            KnowledgeSetupGroup(expandId: $viewModel.expandId, knowledge: $viewModel.knowledge)
                .padding(.trailing, 16)
            GenerationParameterGroup(expandId: $viewModel.expandId, config: $viewModel.config)
                .padding(.trailing, 16)
        }
        Button("Generate") {
            viewModel.onGenerate()
        }
        .buttonStyle(.borderedProminent)
        .rightAligned()
        .padding(.trailing, 16)
    }
    
    // MARK: - contentView
    @MainActor
    private var contentView: some View {
        ScrollView {
            Markdown(viewModel.response)
                .textSelection(.enabled)
                .topAligned()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.white)
    }
    
    // MARK: - prompts
    @ViewBuilder
    private var prompts: some View {
        Text("Prompt")
            .leftAligned()
        TextEditor(text: $viewModel.prompt)
            .padding(.top, 4)
            .frame(height: 100)
            .font(.body)
        Text("System Prompt")
            .padding(.top, 4)
            .leftAligned()
        TextEditor(text: $viewModel.systemPrompt)
            .padding(.top, 4)
            .frame(height: 80)
            .font(.body)
    }

}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Models.self, configurations: config)
    container.mainContext.insert(Models(name: "qwen7b", family: .ollama))
    let appState = AppState()
    let modelViewModel = ModelViewModel(errorBinding: appState.errorBinding, modelContext: container.mainContext)
    let knowledgeViewModel = KnowledgeViewModel(errorBinding: appState.errorBinding, modelContext: container.mainContext)
    @State var viewModel = TextGenerationViewModel(errorBinding: appState.errorBinding, modelContext: container.mainContext)
    
    return TextGenerationView(viewModel: viewModel)
        .environment(modelViewModel)
        .environment(knowledgeViewModel)
        .environment(viewModel)
}
