//
//  OllamaConfig.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/31.
//

import Foundation

@Observable
class LlmConfig {
    var rawInstruct: Bool = false
    var contextLength: Int = 2048
    var temperature: Float = 0.8
    var seed: Int = -1
    var repeatPenalty: Float = 1.1
    var topK: Int = 40
    var topP: Float = 0.9
}
