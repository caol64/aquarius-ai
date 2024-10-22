//
//  ImageGenerationViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation
import CoreGraphics.CGImage
import StableDiffusion
import CoreML

@Observable
class ImageGenerationViewModel: BaseViewModel {
    
    enum LoadState {
        case idle
        case loaded(StableDiffusionPipelineProtocol)
    }
    
    var prompt: String = ""
    var negativePrompt: String = ""
    var selectedModel: Mlmodel?
    var showFileExporter: Bool = false
    var config: DiffusersConfig = .init()
    var modelLoadState: LoadState = .idle
    var generationState: GenerationState<CGImage> = .ready
    var status: String = ""
    var showModelPicker = false
    var expandId: String?
    private let scheduler: StableDiffusionScheduler = .dpmSolverMultistepScheduler
    private let rng: StableDiffusionRNG = .numpyRNG
    private var canceled = false
    
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
        Task {
            do {
                status = "Loading model..."
                let startTime = Date()
                let pipeline = try await load(model: model)
                var interval = Date().timeIntervalSince(startTime)
                self.status = "Model loaded in \(String(format: "%.1f", interval)) s."
                
                canceled = false
                let stepCount: Int = config.stepCount
                let cfgScale: Float = config.cfgScale
                var pipelineConfig = config.isXL ? StableDiffusionXLPipeline.Configuration(prompt: prompt) : StableDiffusionPipeline.Configuration(prompt: prompt)
                
                pipelineConfig.negativePrompt = negativePrompt
                pipelineConfig.startingImage = nil
                pipelineConfig.strength = 0.5
                pipelineConfig.imageCount = config.imageCount
                pipelineConfig.stepCount = stepCount
                if config.seed < 0 {
                    pipelineConfig.seed = UInt32.random(in: 0...UInt32.max)
                } else {
                    pipelineConfig.seed = UInt32(config.seed)
                }
                pipelineConfig.controlNetInputs = []
                pipelineConfig.guidanceScale = cfgScale
                pipelineConfig.schedulerType = scheduler
                pipelineConfig.rngType = rng
                pipelineConfig.useDenoisedIntermediates = true
                pipelineConfig.encoderScaleFactor = config.scaleFactor
                pipelineConfig.decoderScaleFactor = config.scaleFactor
                let images = try pipeline.generateImages(configuration: pipelineConfig,
                                                         progressHandler: { progress in
                    self.status = "Generating progress \(progress.step + 1) / \(progress.stepCount) ..."
                    self.generationState = .running(progress.currentImages[0])
                    return !canceled
                })
                interval = Date().timeIntervalSince(startTime)
                if !canceled {
                    if let image = images[0] {
                        self.generationState = .complete(image)
                        self.status = "Image generated in \(String(format: "%.1f", interval)) s."
                    } else {
                        self.generationState = .failed
                        self.status = "Generate failed."
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
            config.isXL = model.name.lowercased().contains("xl")
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
    
    private func load(model: Mlmodel) async throws -> StableDiffusionPipelineProtocol {
        switch modelLoadState {
        case .idle:
            let startTime = Date()
            let coreMLConfig = MLModelConfiguration()
            coreMLConfig.computeUnits = MLComputeUnits.cpuAndGPU
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
            let pipeline: StableDiffusionPipelineProtocol
            if config.isXL {
if #available(macOS 14.0, iOS 17.0, *) {
                    pipeline = try StableDiffusionXLPipeline(resourcesAt: directory,
                                                             configuration: coreMLConfig,
                                                             reduceMemory: config.reduceMemory)
} else {
                    throw AppError.bizError(description: "Stable Diffusion XL requires macOS 14")
}
            } else {
                pipeline = try StableDiffusionPipeline(resourcesAt: directory,
                                                       controlNet: [],
                                                       configuration: coreMLConfig,
                                                       reduceMemory: config.reduceMemory)
            }
            try pipeline.loadResources()
            let interval = Date().timeIntervalSince(startTime)
            modelLoadState = .loaded(pipeline)
            return pipeline
        case .loaded(let pipeline):
            return pipeline
        }
    }

}
