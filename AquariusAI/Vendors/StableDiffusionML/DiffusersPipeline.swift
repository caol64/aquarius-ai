//
//  DiffusersCoreML.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/2.
//

import Foundation
import StableDiffusion
import CoreML
import UniformTypeIdentifiers

class DiffusersPipeline {
    
    static var shared: DiffusersPipeline?
    private let scheduler: StableDiffusionScheduler = .dpmSolverMultistepScheduler
    private let rng: StableDiffusionRNG = .numpyRNG
    private let pipeline: StableDiffusionPipelineProtocol

    private init(pipeline: StableDiffusionPipelineProtocol) {
        self.pipeline = pipeline
    }

    static func load(endpoint: Endpoint, diffusersConfig: DiffusersConfig) async throws {
        print("start load pipeline")
        let startTime = Date()
        var modelDirectory: URL?
        if let data = UserDefaults.standard.data(forKey: "bookmark_\(endpoint.id)") {
            modelDirectory = restoreFileAccess(with: data, id: endpoint.id)
        }
        guard let directory = modelDirectory else {
            throw AppError.bizError(description: "The model path is invalid, please check it in settings.")
        }
        _ = directory.startAccessingSecurityScopedResource()
        if !isDirectoryReadable(path: directory.path()) {
            throw AppError.directoryNotReadable(path: directory.path())
        }
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        let config = MLModelConfiguration()
        let computeUnits: MLComputeUnits = .cpuAndGPU
        config.computeUnits = computeUnits
        let pipeline: StableDiffusionPipelineProtocol
        if diffusersConfig.isXL {
            if #available(macOS 14.0, iOS 17.0, *) {
                pipeline = try StableDiffusionXLPipeline(resourcesAt: directory,
                                                         configuration: config,
                                                         reduceMemory: diffusersConfig.reduceMemory)
            } else {
                throw AppError.bizError(description: "Stable Diffusion XL requires macOS 14")
            }
        } else {
            pipeline = try StableDiffusionPipeline(resourcesAt: directory,
                                                   controlNet: [],
                                                   configuration: config,
                                                   reduceMemory: diffusersConfig.reduceMemory)
        }
        try pipeline.loadResources()
        let interval = Date().timeIntervalSince(startTime)
        shared = DiffusersPipeline(pipeline: pipeline)
        print("pipeline loaded in \(interval) s")
    }
    
    static func clear() {
        if let instance = shared {
            instance.unload()
            shared = nil
        }
    }
    
    private func unload() {
        pipeline.unloadResources()
        print("unloadResources")
    }
    
    func generate(prompt: String,
                  negativePrompt: String,
                  diffusersConfig: DiffusersConfig,
                  onComplete: @escaping (_ file: CGImage?) -> Void) async throws {
        print("start generate")
        let startTime = Date()
        let stepCount: Int = diffusersConfig.stepCount
        let cfgScale: Float = diffusersConfig.cfgScale
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
//        pipelineConfig.schedulerTimestepSpacing = .karras
        let images = try pipeline.generateImages(configuration: pipelineConfig,
                                                 progressHandler: { progress in
//            sampleTimer.stop()
//            onMessage(GeneralResponse(data: ""))
//            if progress.stepCount != progress.step {
//                sampleTimer.start()
//            }
//            print(progress)
            return true
        })
        let interval = Date().timeIntervalSince(startTime)
        print("Got images: \(images) in \(interval) s")
        

//        let paths: [String] = try saveImages(images, logNames: true, prompt: prompt)
        onComplete(images[0])
    }
    
    func cancelGenerate() {
        
    }
    
}
