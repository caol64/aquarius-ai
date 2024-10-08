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
    @Environment(AppState.self) private var appState
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
                        Button("Copy", systemImage: viewModel.isCopied ? "checkmark" : "clipboard") {
                            viewModel.onCopy()
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
        .monitorWindowFocus(for: .text, appState: appState)
        .frame(minHeight: 580)
        .onAppear() {
            appState.openedWindows.insert(.text)
        }
        .onDisappear() {
            appState.openedWindows.remove(.text)
        }
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
        VStack {
            if case .running = viewModel.generationState {
                Button("Cancel") {
                    
                }
                .frame(width: 100)
            } else if case .preparing = viewModel.generationState {
                Button("Generate") {
                }
                .disabled(true)
                .frame(width: 100)
            } else {
                Button("Generate") {
                    viewModel.onGenerate()
                }
                .frame(width: 100)
            }
        }
        .buttonStyle(.borderedProminent)
        .rightAligned()
        .padding(.trailing, 16)
    }
    
    // MARK: - contentView
    @MainActor
    private var contentView: some View {
        VStack(spacing: 0) {
            switch viewModel.generationState {
            case .startup:
                Spacer()
                ContentUnavailableView {
                    Text("How are you today?")
                }
                Spacer()
            default:
                ScrollView {
                    Markdown(viewModel.response)
                        .markdownCodeSyntaxHighlighter(HighlightrCodeSyntaxHighlighter())
                        .markdownTheme(markdownTheme)
                        .textSelection(.enabled)
                        .topAligned()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(.white)
            }
        }
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
    
    // MARK: - markdownTheme
    @MainActor
    private var markdownTheme: Theme {
        Theme()
            .code {
                FontFamilyVariant(.monospaced)
                FontSize(.em(0.85))
                BackgroundColor(Color(hex: "#FAFAFA"))
                ForegroundColor(Color(hex: "#8D8D8D"))
            }
            .codeBlock { configuration in
                VStack(alignment: .leading) {
                    HStack {
                        Text(configuration.language?.capitalized ?? "")
                            .foregroundStyle(Color(hex: "#8D8D8D"))
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.onCodeblockCopy(code: configuration.content)
                        }) {
                            Label(viewModel.isCodeblockCopied ? "Copied!" : "Copy Code", systemImage: viewModel.isCodeblockCopied ? "checkmark" : "square.on.square.fill")
                                .foregroundColor(Color(hex: "#8D8D8D"))
                        }
                        .buttonStyle(.plain)
                        .cornerRadius(4)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#2F2F2F"))
                    
                    configuration.label
                        .padding(.top, 8)
                        .padding(.bottom)
                        .padding(.horizontal)
                        .monospaced()
                }
                .background(Color(hex: "#272822"))
                .cornerRadius(8)
            }
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
