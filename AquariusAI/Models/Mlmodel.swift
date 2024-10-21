//
//  Mlmodel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftData
import CoreGraphics.CGImage

@Model
class Mlmodel: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var type: ModelType
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    
    init(name: String, type: ModelType? = .llm) {
        self.name = name
        self.type = type ?? .llm
    }
    
}

// MARK: - content generation
extension Mlmodel {
    func generate<C, P, R>(prompt: String,
                           systemPrompt: String,
                           config: C?,
                           onLoad: @escaping (_ interval: TimeInterval) -> Void,
                           onProgress: @escaping (_ progress: P?) -> Void,
                           onComplete: @escaping (_ response: R?, _ interval: TimeInterval) -> Void,
                           onError: @escaping (_ error: AppError) -> Void) async throws {
        if self.type == .diffusers {
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
extension Mlmodel {
    func embedding(texts: [String]) async throws -> [[Double]] {
        throw AppError.bizError(description: "Not implemented.")
    }
}

// MARK: - upscale
extension Mlmodel {
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
