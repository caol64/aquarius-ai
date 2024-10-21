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
    var family: ModelFamily
    var type: ModelType
    var localPath: String = ""
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    
    init(name: String, family: ModelFamily? = .huggingface, type: ModelType? = .text) {
        self.name = name
        self.family = family ?? .huggingface
        self.type = type ?? .text
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
        let model = RealEsrgan(model: self)
        let result = try await model.upscale(image: image)
        return result
    }
}
