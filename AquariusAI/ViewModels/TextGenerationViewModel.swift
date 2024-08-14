//
//  TextGenerationViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/8.
//

import Foundation
import MarkdownUI
import SwiftUI

@Observable
class TextGenerationViewModel: BaseViewModel {
    
    enum GenerationState {
        case startup
        case preparing
        case running
        case complete
        case failed
    }
    
    var prompt: String = ""
    var systemPrompt: String = ""
    var selectedModel: Models?
    var response: String = ""
    var showModelPicker = false
    var config: LlmConfig = LlmConfig()
    var knowledge: Knowledges?
    var expandId: String?
    var isCopied = false
    var generationState: GenerationState = .startup
    
    func closeModelListPopup() {
        showModelPicker = false
    }
    
    func onGenerate() {
        if prompt.isEmpty {
            handleError(error: AppError.promptEmpty)
            return
        }
        guard let model = selectedModel  else {
            handleError(error: AppError.missingModel)
            return
        }
        generationState = .preparing
        response = ""
        Task {
            var promptContext = prompt
            if let knowledge = knowledge {
                promptContext = try await knowledge.ragByKnowledge(prompt: prompt)
            }
            generationState = .running
            try await model.generate(prompt: promptContext, systemPrompt: systemPrompt, config: config) { interval in
            } onProgress: { (text: String?) in
                if let text = text {
                    self.response += text
                }
            } onComplete: { (text: String?, interval) in
                self.generationState = .complete
            } onError: { error in
                self.handleError(error: error)
                self.generationState = .failed
            }
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

}
