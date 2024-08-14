//
//  ImageViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation
import CoreGraphics.CGImage
import StableDiffusion

@Observable
class ImageViewModel: BaseViewModel {
    var prompt: String = ""
    var negativePrompt: String = ""
    var selectedModel: Models?
    var showFileExporter: Bool = false
    var config: DiffusersConfig = DiffusersConfig()
    var generationState: GenerationState = .startup
    var status: String = ""
    var showModelPicker = false
    var expandId: String?
    
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
        guard let model = selectedModel else {
            handleError(error: AppError.missingModel)
            return
        }
        status = ""
        Task {
            do {
                generationState = .loading
                status = "Loading model..."
                generationState = .running(nil)
                try await model.generate(prompt: prompt, systemPrompt: negativePrompt, config: config) { interval in
                    self.status = "Model loaded in \(String(format: "%.1f", interval)) s."
                    self.generationState = .running(nil)
                } onProgress: { (progress: PipelineProgress?) in
                    if let progress = progress {
                        self.status = "Generating progress \(progress.step + 1) / \(progress.stepCount) ..."
                        self.generationState = .running(progress.currentImages[0])
                    }
                } onComplete: { (file: CGImage?, interval) in
                    if let image = file {
                        self.generationState = .complete(image)
                        self.status = "Image generated in \(String(format: "%.1f", interval)) s."
                    } else {
                        self.generationState = .failed
                        self.status = "Generate failed."
                    }
                } onError: { error in
                }
            } catch {
                handleError(error: error)
                status = "Generate failed."
                generationState = .failed
            }
        }
        
    }
    
    func onModelChange() {
        if let model = selectedModel {
            config.isXL = model.name.lowercased().contains("xl")
        }
    }
    
    func onCancel() {
        //        DiffusersPipeline.shared?.cancelGenerate()
        generationState = .startup
    }
    
    func onUpscale(image: CGImage, model: Models) {
        Task {
            do {
                status = "Upscaling..."
                generationState = .running(image)
                let result = try await model.upscale(image: image)
                generationState = .complete(result)
                status = "Upscale successfully"
            } catch {
                self.handleError(error: error)
                status = "Upscale failed."
                generationState = .failed
            }
        }
        
    }

}
