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
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var prompt: String = ""
    @State private var systemPrompt: String = ""
    @State private var selectedEndpoint: Endpoint?
    @State private var response: String = ""
    @State private var showEndpointPicker = false
    @State private var config: OllamaConfig = OllamaConfig()
    @State private var knowledge: Knowledge?
    @State private var expandId: String?
    private let modelFamily: ModelFamily = .ollama
    private let title = "Text Generation"
    
    var body: some View {
        NavigationSplitView {
            VStack {
                generationOptions()
                ScrollView {
                    prompts()
                    KnowledgeSettingGroup(expandId: $expandId, knowledge: $knowledge)
                        .padding(.trailing, 16)
                    GenerationParameterGroup(expandId: $expandId, config: $config)
                        .padding(.trailing, 16)
                }
                Button("Generate") {
                    onGenerate()
                }
                .buttonStyle(.borderedProminent)
                .rightAligned()
                .padding(.trailing, 16)
                
            }
            .topAligned()
            .padding(.leading, 16)
            .navigationSplitViewColumnWidth(300)
        } detail: {
            ScrollView {
                Markdown(response)
                    .textSelection(.enabled)
                    .topAligned()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.white)
            .navigationTitle("")
            .navigationSplitViewColumnWidth(min: 750, ideal: 750, max: .infinity)
            .toolbar {
                EndpointToolbar(endpoint: $selectedEndpoint, showEndpointPicker: $showEndpointPicker, title: title, modelFamily: modelFamily)
                ToolbarItemGroup {
                    Button("Copy", systemImage: "clipboard") {
                        
                    }
                }
            }
            .overlay(alignment: .top) {
                if showEndpointPicker {
                    EndpointsList(endpoint: $selectedEndpoint, modelFamily: modelFamily)
                }
            }
        }
        .onTapGesture {
            if showEndpointPicker {
                showEndpointPicker = false
            }
        }
        .frame(minHeight: 580)
    }
    
    private func prompts() -> some View {
        VStack {
            Text("Prompt")
                .leftAligned()
            TextEditor(text: $prompt)
                .padding(.top, 4)
                .frame(height: 100)
                .font(.body)
            Text("System Prompt")
                .padding(.top, 4)
                .leftAligned()
            TextEditor(text: $systemPrompt)
                .padding(.top, 4)
                .frame(height: 80)
                .font(.body)
        }
    }
    
    // MARK: - Actions
    private func onGenerate() {
        if prompt.isEmpty {
            errorBinding.appError = AppError.promptEmpty
            return
        }
        guard let endpoint = selectedEndpoint  else {
            errorBinding.appError = AppError.missingModel
            return
        }
        response = ""
        Task {
            try await OllamaService.shared.callGenerateApi(prompt: prompt, systemPrompt: systemPrompt, endpoint: endpoint, config: config) { response in
                self.response += response.response
            } onComplete: { data in
                
            } onError: { error in
                errorBinding.appError = AppError.unexpected(description: error.localizedDescription)
            }
        }
    }

}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Endpoint.self, configurations: config)
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .ollama))
    let errorBinding = ErrorBinding()
    EndpointViewModel.shared.configure(modelContext: container.mainContext, errorBinding: errorBinding)
    
    return TextGenerationView()
        .environment(errorBinding)
}
