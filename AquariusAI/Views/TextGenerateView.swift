//
//  TextGenerateView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI
import SwiftData
import MarkdownUI

struct TextGenerateView: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var prompt: String = ""
    @State private var systemPrompt: String = ""
    @State private var modelName: String = ""
    @State private var endpoint: Endpoint?
    @State private var agent: Agent?
    @State private var response: String = ""
    private let endpointService = EndpointService.shared
    
    var body: some View {
        NavigationSplitView {
            VStack() {
                genrateOptions()
                prompts()
                
                ModelPicker(endpoint: $endpoint, modelFamily: .ollama)
                    .padding(.top, 8)
                    .onChange(of: endpoint) {
                        onModelChange()
                    }
                
                AgentPicker(agent: $agent)
                    .padding(.top, 8)
                    .onChange(of: agent) {
                        onAgentChange()
                    }
                
                Button("Generate", role: .destructive) {
                    onGenerate()
                }
                .buttonStyle(.borderedProminent)
                .rightAligned()
                .padding(.top, 8)
                
            }
            .topAligned()
            .padding()
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
            .navigationSplitViewColumnWidth(min: 600, ideal: 600, max: 900)
            .toolbar {
                Button("Copy", systemImage: "clipboard") {
                    
                }
            }
        }
        .onDisappear {
            print("onDisappear")
        }
        
    }
    
    private func prompts() -> some View {
        VStack {
            Text("Prompt")
                .padding(.top, 8)
                .leftAligned()
            TextField("", text: $prompt, axis: .vertical)
                .lineLimit(7...7)
            Text("System Prompt")
                .padding(.top, 4)
                .leftAligned()
            TextField("", text: $systemPrompt, axis: .vertical)
                .lineLimit(3...3)
        }
    }
    
    // MARK: - Actions
    private func onGenerate() {
        if prompt.isEmpty {
            errorBinding.appError = AppError.promptEmpty
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
        response = ""
        Task {
            try await OllamaService.shared.callGenerateApi(prompt: prompt, endpoint: endpoint, agent: agent) { response in
                self.response += response.response
            } onComplete: { data in
                
            } onError: { error in
                print(error)
                errorBinding.appError = AppError.unexpected(description: error.localizedDescription)
            }
        }
    }
    
    private func onModelChange() {
        print("onModelChange")
    }
    
    private func onAgentChange() {
        if let agent = agent {
            systemPrompt = agent.systemPrompt
        }
    }
    
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Endpoint.self, configurations: config)
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .ollama))
    EndpointService.shared.configure(with: container.mainContext)
    
    return TextGenerateView()
        .environment(ErrorBinding())
}
