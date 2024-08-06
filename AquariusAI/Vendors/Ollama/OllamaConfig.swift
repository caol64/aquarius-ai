//
//  OllamaConfig.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/31.
//

import Foundation

@Observable
class OllamaConfig {
    static let defaultSystemPrompt = "You are Aquarius, a helpful assistant."
    var rawInstruct: Bool = false
    var contextLength: Int = 2048
    var temperature: Double = 0.8
    var seed: Int = -1
    var repeatPenalty: Double = 1.1
    var topK: Int = 40
    var topP: Double = 0.9
}
