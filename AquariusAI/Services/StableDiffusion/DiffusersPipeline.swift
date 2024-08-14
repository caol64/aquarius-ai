//
//  DiffusersCoreML.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/2.
//

import Foundation
import StableDiffusion
import CoreML

class DiffusersPipeline {
    
    private let scheduler: StableDiffusionScheduler = .dpmSolverMultistepScheduler
    private let rng: StableDiffusionRNG = .numpyRNG
    private var pipeline: StableDiffusionPipelineProtocol?
    private let model: Models
    private let diffusersConfig: DiffusersConfig
    private var canceled = false

    init(model: Models, diffusersConfig: DiffusersConfig) {
        self.model = model
        self.diffusersConfig = diffusersConfig
    }
    
    deinit {
        pipeline?.unloadResources()
    }

    private func loadModel(modelDirectory: URL) async throws -> TimeInterval {
        let startTime = Date()
        let config = MLModelConfiguration()
        let computeUnits: MLComputeUnits = .cpuAndGPU
        config.computeUnits = computeUnits
        if diffusersConfig.isXL {
            if #available(macOS 14.0, iOS 17.0, *) {
                pipeline = try StableDiffusionXLPipeline(resourcesAt: modelDirectory,
                                                         configuration: config,
                                                         reduceMemory: diffusersConfig.reduceMemory)
            } else {
                throw AppError.bizError(description: "Stable Diffusion XL requires macOS 14")
            }
        } else {
            pipeline = try StableDiffusionPipeline(resourcesAt: modelDirectory,
                                                   controlNet: [],
                                                   configuration: config,
                                                   reduceMemory: diffusersConfig.reduceMemory)
        }
        try pipeline?.loadResources()
        let interval = Date().timeIntervalSince(startTime)
        return interval
    }
    
    func generate(prompt: String,
                  negativePrompt: String,
                  onLoadComplete: (_ interval: TimeInterval) -> Void,
                  onGenerateComplete: @escaping (_ file: CGImage?, _ interval: TimeInterval) -> Void,
                  onProgress: (_ progress: PipelineProgress) -> Void) async throws {
        let startTime = Date()
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
        var interval = try await loadModel(modelDirectory: directory)
        onLoadComplete(interval)
        
        canceled = false
        let stepCount: Int = diffusersConfig.stepCount
        let cfgScale: Float = Float(diffusersConfig.cfgScale)
        var pipelineConfig = diffusersConfig.isXL ? StableDiffusionXLPipeline.Configuration(prompt: prompt) : StableDiffusionPipeline.Configuration(prompt: prompt)
        
        pipelineConfig.negativePrompt = negativePrompt
        pipelineConfig.startingImage = nil
        pipelineConfig.strength = 0.5
        pipelineConfig.imageCount = diffusersConfig.imageCount
        pipelineConfig.stepCount = stepCount
        if diffusersConfig.seed < 0 {
            pipelineConfig.seed = UInt32.random(in: 0...UInt32.max)
        } else {
            pipelineConfig.seed = UInt32(diffusersConfig.seed)
        }
        pipelineConfig.controlNetInputs = []
        pipelineConfig.guidanceScale = cfgScale
        pipelineConfig.schedulerType = scheduler
        pipelineConfig.rngType = rng
        pipelineConfig.useDenoisedIntermediates = true
        pipelineConfig.encoderScaleFactor = diffusersConfig.scaleFactor
        pipelineConfig.decoderScaleFactor = diffusersConfig.scaleFactor
        let images = try pipeline!.generateImages(configuration: pipelineConfig,
                                                 progressHandler: { progress in
            onProgress(progress)
            return !canceled
        })
        interval = Date().timeIntervalSince(startTime)
        if !canceled {
            onGenerateComplete(images[0], interval)
        }
    }
    
    func cancelGenerate() {
        canceled = true
    }
    
}
