//
//  Models.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftData
import CoreGraphics.CGImage

@Model
class Models: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var family: ModelFamily
    var type: ModelType
    var host: String
    var endpoint: String?
    var appkey: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    
    init(name: String, family: ModelFamily, type: ModelType? = .llm) {
        self.name = name
        self.family = family
        self.host = family.host
        self.type = type ?? .llm
    }
    
}

// MARK: - content generation
extension Models {
    func generate<C, P, R>(prompt: String,
                           systemPrompt: String,
                           config: C?,
                           onLoad: @escaping (_ interval: TimeInterval) -> Void,
                           onProgress: @escaping (_ progress: P?) -> Void,
                           onComplete: @escaping (_ response: R?, _ interval: TimeInterval) -> Void,
                           onError: @escaping (_ error: AppError) -> Void) async throws {
        if self.family == .ollama {
            try await OllamaService.shared.callGenerateApi(prompt: prompt, systemPrompt: systemPrompt, model: self, config: config as! LlmConfig) { response in
                onProgress(response.response as? P)
            } onComplete: { data, interval in
                onComplete(data as? R, interval)
            } onError: { error in
                onError(error)
            }
        } else if self.type == .diffusers {
            let pipeline = DiffusersPipeline(model: self, diffusersConfig: config as! DiffusersConfig)
            try await pipeline.generate(prompt: prompt, negativePrompt: systemPrompt) { interval in
                onLoad(interval)
            } onGenerateComplete: { data, interval in
                onComplete(data as? R, interval)
            } onProgress: { progress in
                onProgress(progress as? P)
            }
        } else {
            throw AppError.bizError(description: "Not implemented.")
        }
    }
}

// MARK: - embedding
extension Models {
    func embedding(texts: [String]) async throws -> [[Double]] {
        switch self.family {
        case .ollama:
            return try await OllamaService.shared.callEmbeddingApi(prompts: texts, model: self)
        default:
            throw AppError.bizError(description: "Not implemented.")
        }
    }
}

// MARK: - sync remote models
extension Models {
    
    func sync() async throws -> [String] {
        switch self.family {
        case .ollama:
            return try await OllamaService.shared.fetchModels(host: self.host)
        default:
            throw AppError.bizError(description: "Not implemented.")
        }
    }
}

// MARK: - upscale
extension Models {
    
    func upscale(image: CGImage) async throws -> CGImage {
        if self.type == .esrgan {
            let model = RealEsrgan(model: self)
            let result = try await model.upscale(image: image)
            return result
        } else {
            throw AppError.bizError(description: "Not implemented.")
        }
    }
}
