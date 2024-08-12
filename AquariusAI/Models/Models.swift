//
//  Models.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftData

@Model
class Models: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var family: String
    var host: String?
    var endpoint: String?
    var appkey: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    
    init(name: String, modelFamily: ModelFamily) {
        self.name = name
        self.family = modelFamily.rawValue
        self.host = modelFamily.host
    }
    
    var modelFamily: ModelFamily {
        get {
            return ModelFamily(rawValue: family)!
        }
        set {
            family = newValue.rawValue
        }
    }
    
}

extension Models {
    func generate<C, P, R>(prompt: String,
                           systemPrompt: String,
                           config: C?,
                           onProgress: @escaping (_ progress: P?) -> Void,
                           onComplete: @escaping (_ response: R?) -> Void,
                           onError: @escaping (_ error: AppError) -> Void) async throws {
        switch self.modelFamily {
        case .ollama:
            try await OllamaService.shared.callGenerateApi(prompt: prompt, systemPrompt: systemPrompt, model: self, config: config as! OllamaConfig) { response in
                onProgress(response.response as? P)
            } onComplete: { data in
                onComplete(data as? R)
            } onError: { error in
                onError(error)
            }
        case .gpt:
            return
        case .gemini:
            return
        case .diffusers:
            return
        case .mlmodel:
            return
        }
    }
}

