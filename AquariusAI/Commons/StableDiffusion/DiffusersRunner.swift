//
//  DiffusersRunner.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/11/14.
//

import Foundation
import StableDiffusion
import CoreML

actor DiffusersRunner {
    
    func load(config: DiffusersConfig,
              model: Mlmodel) async throws -> StableDiffusionPipelineProtocol {
        let coreMLConfig = MLModelConfiguration()
        coreMLConfig.computeUnits = MLComputeUnits.all
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
            pipeline = try StableDiffusionXLPipeline(resourcesAt: directory,
                                                     configuration: coreMLConfig,
                                                     reduceMemory: config.reduceMemory)
        } else if config.isSD3 {
            pipeline = try StableDiffusion3Pipeline(resourcesAt: directory,
                                                    configuration: coreMLConfig,
                                                    reduceMemory: config.reduceMemory)
        } else {
            pipeline = try StableDiffusionPipeline(resourcesAt: directory,
                                                   controlNet: [],
                                                   configuration: coreMLConfig,
                                                   reduceMemory: config.reduceMemory)
        }
        try pipeline.loadResources()
        return pipeline
    }
    
    func generate(pipelineConfig: PipelineConfiguration,
                  pipeline: StableDiffusionPipelineProtocol,
                  progressHandler: (PipelineProgress) -> Bool) async throws -> CGImage? {
        let images = try pipeline.generateImages(configuration: pipelineConfig) { progress in
            progressHandler(progress)
        }
        if let image = images[0] {
            return image
        } else {
            return nil
        }
    }
}
