//
//  ModelType.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/12.
//

import Foundation

enum ModelType: String, CaseIterable, Identifiable, Codable {
    case text = "Text"
    case image = "Image"
    case embedding = "Embedding"
    case upscale = "Upscale"
    
    var id: Self { self }
    
    var supportedFamily: [ModelFamily] {
        switch self {
        case .text:
            return [.huggingface]
        case .image:
            return [.coreml]
        case .embedding:
            return [.huggingface]
        case .upscale:
            return [.huggingface]
        }
    }
}
