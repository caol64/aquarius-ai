//
//  TextGenerationViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/8.
//

import Foundation
import MarkdownUI
import SwiftUI
import Tokenizers

@Observable
class TextGenerationViewModel: BaseViewModel {
    enum LoadState {
        case idle
        case loaded(TFLanguageModel)
    }
    
    var prompt: String = ""
    var systemPrompt: String = ""
    var selectedModel: Mlmodel?
    var response: String = ""
    var showModelPicker = false
    var knowledge: Knowledge?
    var expandId: String?
    var isCopied = false
    var contextLength: Int = 2048
    var temperature: Float = 0.8
    var seed: Int = -1
    var repeatPenalty: Float = 1.1
    var topK: Int = 40
    var topP: Float = 0.9
    var generationState: GenerationState<String> = .ready
    private var modelLoadState: LoadState = .idle
    private let runner: TransformerRunner = .init()
    
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
        generationState = .running("")
        let config = TransformerConfig(contextLength: contextLength, temperature: temperature, seed: seed, repeatPenalty: repeatPenalty, topK: topK, topP: topP)
        Task {
            let startTime = Date()
            let languageModel: TFLanguageModel
            switch modelLoadState {
            case .idle:
                languageModel = try await runner.load(config: config, model: model)
            case .loaded(let theModel):
                languageModel = theModel
            }
            let interval = Date().timeIntervalSince(startTime)
            let prompt = "\(prompt)\n"
//            let prompt = """
//<|im_start|>system
//\(systemPrompt)
//<|im_end|><|im_start|>user
//\(prompt)
//<|im_end|><|im_start|>assistant
//"""
            let generationConfig = config.toGenerationConfig()
            var tokensReceived = 0
            let result = try await runner.generate(prompt: prompt, languageModel: languageModel, generationConfig: generationConfig) { inProgressGeneration in
                print(inProgressGeneration)
                tokensReceived += 1
                self.generationState = .running(inProgressGeneration)
            }
            generationState = .complete(result)
            response = result
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

}
