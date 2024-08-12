//
//  ImageViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation
import CoreGraphics.CGImage

@Observable
class ImageViewModel: BaseViewModel {
    var prompt: String = ""
    var negativePrompt: String = ""
    var selectedModel: Models?
    var showFileExporter: Bool = false
    var config: DiffusersConfig = DiffusersConfig()
    var generationState: GenerationState = .startup
    var status: String = ""
    var upscalerModel: Models?
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
        status = ""
        guard let model = selectedModel else {
            handleError(error: AppError.missingModel)
            return
        }
        Task {
            do {
                generationState = .loading
                status = "Loading model..."
                let pipeline = DiffusersPipeline(model: model, diffusersConfig: config)
                generationState = .running(nil)
                try await pipeline.generate(prompt: prompt, negativePrompt: negativePrompt) { interval in
                    status = "Model loaded in \(String(format: "%.1f", interval)) s."
                    generationState = .running(nil)
                } onGenerateComplete: { file, interval in
                    if let image = file {
                        self.generationState = .complete(image)
                        self.status = "Image generated in \(String(format: "%.1f", interval)) s."
                    } else {
                        self.generationState = .failed
                        self.status = "Generate failed."
                    }
                } onProgress: { progress in
                    status = "Generating progress \(progress.step + 1) / \(progress.stepCount) ..."
                    generationState = .running(progress.currentImages[0])
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
    
    func onUpscale(image: CGImage) {
        guard let upscalerModel = upscalerModel else {
            return
        }
        let model = RealEsrgan(model: upscalerModel)
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
