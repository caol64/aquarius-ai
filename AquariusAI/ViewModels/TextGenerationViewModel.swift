//
//  TextGenerationViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/8.
//

import Foundation
import MarkdownUI
import SwiftUI
import MLXLLM
import MLX
import Tokenizers

@Observable
class TextGenerationViewModel: BaseViewModel {
    
    enum LoadState {
        case idle
        case loaded(ModelContainer)
    }
    
    var prompt: String = ""
    var systemPrompt: String = ""
    var selectedModel: Mlmodel?
    var response: String = ""
    var showModelPicker = false
    var config: LlmConfig = LlmConfig()
    var knowledge: Knowledge?
    var expandId: String?
    var isCopied = false
    var modelLoadState: LoadState = .idle
    var gpuActiveMemory: Int = 0
    var generationState: GenerationState<String> = .ready
    
    func closeModelListPopup() {
        showModelPicker = false
    }
    
    func onGenerate() {
        if case .running = generationState {
            return
        }
        if prompt.isEmpty {
            handleError(error: AppError.promptEmpty)
            return
        }
        guard let model = selectedModel  else {
            handleError(error: AppError.missingModel)
            return
        }
        let parameters = GenerateParameters(
            temperature:  config.temperature,
            topP: config.topP,
            repetitionPenalty: config.repeatPenalty,
            repetitionContextSize: 20
        )
        generationState = .running("")
        Task {
            let (modelConfiguration, modelContainer) = try await load(model: model)
            let prompt = """
<|im_start|>system
\(systemPrompt)
<|im_end|><|im_start|>user
\(prompt)
<|im_end|><|im_start|>assistant
"""
            let promptTokens = await modelContainer.perform { _, tokenizer in
                let promptTokens = tokenizer.encode(text: prompt)
                return promptTokens
            }
//            logger.info(prompt)
            let result = await modelContainer.perform { model, tokenizer in
                return MLXLLM.generate(
                    promptTokens: promptTokens,
                    parameters: parameters,
                    model: model,
                    tokenizer: tokenizer,
                    extraEOSTokens: modelConfiguration.extraEOSTokens.union([
                        "<|im_end|>", "<|end|>",
                    ])
                ) { tokens in
                    let text = tokenizer.decode(tokens: tokens)
//                    self.response = text
                    generationState = .running(text)

                    if tokens.count >= 1024 {
                        return .stop
                    } else {
                        return .more
                    }
                }
            }
            generationState = .complete(result.output)
            response = result.output
        }
    }
    
    func onCopy() {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(response, forType: .string)
        
        isCopied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.isCopied = false
            }
        }
    }
    
    func onCodeblockCopy(code: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(code, forType: .string)
    }
    
    private func load(model: Mlmodel) async throws -> (ModelConfiguration, ModelContainer) {
        let modelConfiguration: ModelConfiguration = ModelConfiguration(directory: URL(filePath: model.localPath))
        switch modelLoadState {
        case .idle:
            let cacheLimit = 128 * 1024 * 1024
            MLX.GPU.set(cacheLimit: cacheLimit)
            var modelDirectory: URL?
            if let data = model.bookmark {
                modelDirectory = restoreFileAccess(with: data) { data in
                    model.bookmark = data
                }
            }
            guard let directory = modelDirectory else {
                throw AppError.bizError(description: "The model path is invalid, please check it in settings.")
            }
            _ = directory.startAccessingSecurityScopedResource()
            defer {
                directory.stopAccessingSecurityScopedResource()
            }
            if !isDirectoryReadable(path: directory.path()) {
                throw AppError.directoryNotReadable(path: directory.path())
            }
            let modelContainer = try await MLXLLM.loadModelContainer(configuration: modelConfiguration)

            withAnimation {
                gpuActiveMemory = MLX.GPU.activeMemory / 1024 / 1024
            }

            modelLoadState = .loaded(modelContainer)
            return (modelConfiguration, modelContainer)

        case .loaded(let modelContainer):
            return (modelConfiguration, modelContainer)
        }
    }

}
