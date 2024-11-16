//
//  TransformerConfig.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/11/13.
//

import Foundation
import Generation

struct TransformerConfig {
    let maxNewTokens: Int = 20
    let contextLength: Int
    let temperature: Float
    let seed: Int
    let repeatPenalty: Float
    let topK: Int
    let topP: Float
}

extension TransformerConfig {
    func toGenerationConfig() -> GenerationConfig {
        return GenerationConfig(maxNewTokens: maxNewTokens)
    }
}
