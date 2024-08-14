//
//  OllamaService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/10.
//

import Combine
import Foundation

class OllamaService {
    
    private var generation: AnyCancellable?
    //    private var cancellables = Set<AnyCancellable>()
    static let shared = OllamaService()
    
    private init() {}
    
    private func convertOptions(config: LlmConfig) -> Ollama.Options {
        var options: Ollama.Options = Ollama.Options()
        options.numCtx = config.contextLength
        options.temperature = config.temperature
        options.seed = config.seed
        options.repeatPenalty = config.repeatPenalty
        options.topK = config.topK
        options.topP = config.topP
        return options
    }
}

// MARK: - Cancel Request
extension OllamaService {
    func cancelGenerate() {
        generation?.cancel()
        Ollama.shared.cancelRequest()
    }
}

// MARK: - List Local Models
extension OllamaService {
    func fetchModels(host: String) async throws -> [String] {
        let response: Ollama.ModelResponse = try await Ollama.shared.models(host: host)
        let responseModels: [Ollama.ModelResponse.Model] = response.models
        var models: [String] = []
        for responseModel in responseModels {
            models.append(responseModel.name)
        }
        return models
    }
}

// MARK: - Call Generate Api
extension OllamaService {
    func callGenerateApi(prompt: String,
                         systemPrompt: String,
                         model: Models,
                         config: LlmConfig,
                         onMessage: @escaping (_ response: Ollama.GenerateResponse) -> Void,
                         onComplete: @escaping (_ data: String?, _ interval: TimeInterval) -> Void,
                         onError: @escaping (_ error: AppError) -> Void) async throws {
        let startTime = Date()
        var request: Ollama.GenerateRequest = Ollama.GenerateRequest(model: model.endpoint ?? "", prompt: prompt)
        request.raw = config.rawInstruct
        if config.rawInstruct {
            request.prompt = systemPrompt.replacingOccurrences(of: "{{user}}", with: prompt)
        } else {
            request.system = systemPrompt
            request.prompt = "\(systemPrompt)\n\(prompt)"
        }
        request.options = convertOptions(config: config)
        generation = try await Ollama.shared.generate(host: model.host, data: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    let interval = Date().timeIntervalSince(startTime)
                    onComplete(nil, interval)
                case .failure(let error):
                    onError(AppError.networkError(description: error.localizedDescription))
                }
            }, receiveValue: { response in
                onMessage(response)
            })
        //            .store(in: &cancellables)
    }
}

// MARK: - Call Embedding Api
extension OllamaService {
    func callEmbeddingApi(prompts: [String],
                          model: Models) async throws -> [[Double]] {
        let request = Ollama.EmbeddingRequest(model: model.endpoint ?? "", input: prompts)
        let response = try await Ollama.shared.embeddings(host: model.host, data: request)
        return response.embeddings
    }

}
