//
//  TextGenerationView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI
import MarkdownUI

struct TextGenerationView: View {
    @Environment(AppState.self) private var appState
    @Environment(TextGenerationViewModel.self) private var viewModel
    let title = "Text Generation"

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationSplitView {
            VStack {
                generationOptions()
                ScrollView {
                    prompts
                    KnowledgeSetupGroup(expandId: $viewModel.expandId, knowledge: $viewModel.knowledge)
                        .padding(.trailing, 16)
                    GenerationParameterGroup(expandId: $viewModel.expandId, contextLength: $viewModel.contextLength, temperature: $viewModel.temperature, seed: $viewModel.seed, repeatPenalty: $viewModel.repeatPenalty, topP: $viewModel.topP)
                        .padding(.trailing, 16)
                }
                VStack {
                    if case .running = viewModel.generationState {
                        Button("Cancel") {
                            
                        }
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
            .topAligned()
            .padding(.leading, 16)
            .navigationSplitViewColumnWidth(300)
        } detail: {
            VStack(spacing: 0) {
                switch viewModel.generationState {
                case .running(let text):
                    if let text = text {
                        markdownView(text: text)
                    }
                case .complete(_):
                    markdownView(text: viewModel.response)
                default:
                    Spacer()
                    ContentUnavailableView {
                        Text("How are you today?")
                    }
                    Spacer()
                }
            }
            .navigationSplitViewColumnWidth(min: 750, ideal: 750, max: .infinity)
            .navigationTitle("")
            .toolbar {
                ModelPickerToolbar(model: $viewModel.selectedModel, showModelPicker: $viewModel.showModelPicker, title: title, modelType: .text)
                ToolbarItemGroup {
                    Button("Copy", systemImage: viewModel.isCopied ? "checkmark" : "clipboard") {
                        viewModel.onCopy()
                    }
                }
            }
            .overlay(alignment: .top) {
                if viewModel.showModelPicker {
                    ModelListPopup(model: $viewModel.selectedModel, modelType: .text)
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
    
    // MARK: - prompts
    @ViewBuilder
    private var prompts: some View {
        @Bindable var viewModel = viewModel
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
    
    // MARK: - markdownView
    private func markdownView(text: String) -> some View {
        ScrollView {
            Markdown(MarkdownContent(text))
                .markdownCodeSyntaxHighlighter(HighlightrCodeSyntaxHighlighter.shared)
                .markdownTheme(.customGitHub)
                .textSelection(.enabled)
                .topAligned()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.white)
    }

}
