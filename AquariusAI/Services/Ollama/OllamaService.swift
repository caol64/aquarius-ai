//
//  OllamaService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/10.
//

import Combine

class OllamaService {
    
    private var generation: AnyCancellable?
    //    private var cancellables = Set<AnyCancellable>()
    static let shared = OllamaService()
    
    private init() {}
    
    private func convertOptions(config: OllamaConfig) -> Ollama.Options {
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
                         config: OllamaConfig,
                         onMessage: @escaping (_ response: Ollama.GenerateResponse) -> Void,
                         onComplete: @escaping (_ data: String?) -> Void,
                         onError: @escaping (_ error: AppError) -> Void) async throws {
        var request: Ollama.GenerateRequest = Ollama.GenerateRequest(model: model.endpoint ?? "", prompt: prompt)
        request.raw = config.rawInstruct
        if config.rawInstruct {
            request.prompt = systemPrompt.replacingOccurrences(of: "{{user}}", with: prompt)
        } else {
            request.system = systemPrompt
            request.prompt = "\(systemPrompt)\n\(prompt)"
        }
        request.options = convertOptions(config: config)
        generation = try await Ollama.shared.generate(host: model.host ?? "", data: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    onComplete(nil)
                case .failure(let error):
                    onError(AppError.networkError(description: error.localizedDescription))
                }
            }, receiveValue: { response in
                onMessage(response)
            })
        //            .store(in: &cancellables)
    }
}

// MARK: - Call Completion Api
extension OllamaService {
    func callCompletionApi(messages: [Messages],
                           systemPrompt: String,
                           model: Models,
                           config: OllamaConfig,
                           onMessage: @escaping (_ response: Ollama.CompletionResponse) -> Void,
                           onComplete: @escaping (_ file: String?) -> Void,
                           onError: @escaping (_ error: AppError) -> Void) async throws {
        var messageContents = messages.map { $0.encode() }
        messageContents.insert(["role": Role.system.rawValue, "content": systemPrompt], at: 0)
        var request: Ollama.CompletionRequest = Ollama.CompletionRequest(model: model.endpoint ?? "", messages: messageContents)
        request.options = convertOptions(config: config)
        generation = try await Ollama.shared.completion(host: model.host ?? "", data: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    onComplete(nil)
                case .failure(let error):
                    onError(AppError.networkError(description: error.localizedDescription))
                }
            }, receiveValue: { response in
                onMessage(response)
            })
    }
}

// MARK: - Call Embedding Api
extension OllamaService {
    func callEmbeddingApi(prompts: [String],
                          model: Models) async throws -> [[Double]] {
        let request = Ollama.EmbeddingRequest(model: model.endpoint ?? "", input: prompts)
        let response = try await Ollama.shared.embeddings(host: model.host ?? "", data: request)
        return response.embeddings
    }
    
    func callEmbeddingApi(prompt: String,
                          model: Models) async throws -> [[Double]] {
        return try await callEmbeddingApi(prompts: [prompt], model: model)
    }

}
