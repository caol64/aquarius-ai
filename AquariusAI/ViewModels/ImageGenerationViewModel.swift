//
//  ImageGenerationViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation
import CoreGraphics.CGImage
import StableDiffusion

@Observable
@MainActor
class ImageGenerationViewModel: BaseViewModel {
    
    enum LoadState {
        case idle
        case loaded(StableDiffusionPipelineProtocol)
    }
    
    var prompt: String = ""
    var negativePrompt: String = ""
    var selectedModel: Mlmodel?
    var showFileExporter: Bool = false
    var generationState: GenerationState<CGImage> = .ready
    var status: String = ""
    var showModelPicker = false
    var expandId: String?
    var stepCount: Int = 6
    var cfgScale: Float = 2.0
    var isXL: Bool = true
    var isSD3: Bool = false
    var seed: Int = -1
    private var canceled = false
    private var modelLoadState: LoadState = .idle
    private let runner: DiffusersRunner = .init()
    
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
        generationState = .running(nil)
        canceled = false
        status = "Loading model..."
        let config = DiffusersConfig(stepCount: stepCount, cfgScale: cfgScale, isXL: isXL, isSD3: isSD3, seed: seed)
        Task {
            do {
                let startTime = Date()
                let pipeline: StableDiffusionPipelineProtocol
                switch modelLoadState {
                case .idle:
                    pipeline = try await runner.load(config: config, model: model)
                case .loaded(let thePipeline):
                    pipeline = thePipeline
                }
                var interval = Date().timeIntervalSince(startTime)
                self.status = "Model loaded in \(String(format: "%.1f", interval)) s."
                let pipelineConfig = config.toPipelineConfig(prompt: prompt, negativePrompt: negativePrompt)
                let image = try await runner.generate(pipelineConfig: pipelineConfig, pipeline: pipeline) { progress in
                    self.status = "Generating progress \(progress.step + 1) / \(progress.stepCount) ..."
                    self.generationState = .running(progress.currentImages[0])
                    return !canceled
                }
                interval = Date().timeIntervalSince(startTime)
                self.status = "Image generated in \(String(format: "%.1f", interval)) s."
                if !canceled {
                    if let image = image {
                        self.generationState = .complete(image)
                    } else {
                        self.generationState = .failed
                    }
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
            isXL = model.name.lowercased().contains("xl")
        }
    }
    
    func onCancel() {
        canceled = true
        generationState = .ready
    }
    
    func onUpscale(image: CGImage, model: Mlmodel) {
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
