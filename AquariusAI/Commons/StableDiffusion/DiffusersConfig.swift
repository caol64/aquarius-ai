//
//  DiffusersConfig.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/28.
//
import Foundation
import StableDiffusion

enum ImageRatio: String, CaseIterable, Identifiable {
    case oneOne = "1:1"
    case sixteenNine = "16:9"
    case nineSixteen = "9:16"
    
    var id: Self { self }
}

struct DiffusersConfig {

    let stepCount: Int
    let cfgScale: Float
    let isXL: Bool
    let isSD3: Bool
    let seed: Int
    let imageRatio: ImageRatio = .oneOne
    let scheduler: StableDiffusionScheduler = .dpmSolverMultistepScheduler
    
    init(stepCount: Int, cfgScale: Float, isXL: Bool, isSD3: Bool, seed: Int) {
        self.stepCount = stepCount
        self.cfgScale = cfgScale
        self.isXL = isXL
        self.isSD3 = isSD3
        self.seed = seed
    }
    
    var reduceMemory: Bool {
        #if os(macOS)
            return false
        #else
            return true
        #endif
    }
    
    var scaleFactor: Float32 {
        if isSD3 {
            return 1.5305
        }
        return 0.13025
    }
    var width: Int {
        if isXL {
            switch imageRatio {
            case .oneOne:
                return 1024
            case .sixteenNine:
                return 1360
            case .nineSixteen:
                return 768
            }
        } else {
            switch imageRatio {
            case .oneOne:
                return 512
            case .sixteenNine:
                return 680
            case .nineSixteen:
                return 384
            }
        }
    }
    var height: Int {
        if isXL {
            switch imageRatio {
            case .oneOne:
                return 1024
            case .sixteenNine:
                return 768
            case .nineSixteen:
                return 1360
            }
        } else {
            switch imageRatio {
            case .oneOne:
                return 512
            case .sixteenNine:
                return 384
            case .nineSixteen:
                return 680
            }
        }
    }

}

extension DiffusersConfig {
    func toPipelineConfig(prompt: String, negativePrompt: String) -> PipelineConfiguration {
        var config = StableDiffusionPipeline.Configuration(prompt: prompt)
        config.negativePrompt = negativePrompt
        config.stepCount = stepCount
        if seed < 0 {
            config.seed = UInt32.random(in: 0...UInt32.max)
        } else {
            config.seed = UInt32(seed)
        }
        config.guidanceScale = cfgScale
        config.disableSafety = true
        config.schedulerType = scheduler
        config.useDenoisedIntermediates = true
        config.encoderScaleFactor = scaleFactor
        config.decoderScaleFactor = scaleFactor
        if isXL {
            config.schedulerTimestepSpacing = .karras
        }
        if isSD3 {
            config.decoderShiftFactor = 0.0609
            config.schedulerTimestepShift = 3.0
        }
        return config
    }
}
