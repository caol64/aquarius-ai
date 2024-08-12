//
//  TextGenerationViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/8.
//

import Foundation

@Observable
class TextGenerationViewModel: BaseViewModel {
    var prompt: String = ""
    var systemPrompt: String = ""
    var selectedModel: Models?
    var response: String = ""
    var showModelPicker = false
    var config: LlmConfig = LlmConfig()
    var knowledge: Knowledges?
    var expandId: String?
    
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
        response = ""
        Task {
            try await model.generate(prompt: prompt, systemPrompt: systemPrompt, config: config) { interval in
            } onProgress: { (text: String?) in
                if let text = text {
                    self.response += text
                }
            } onComplete: { (text: String?, interval) in
            } onError: { error in
                self.handleError(error: error)
            }
        }
    }

}
