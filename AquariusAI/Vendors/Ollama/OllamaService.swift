//
//  OllamaService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/10.
//

import Combine

class OllamaService {
    
    private let modelFamily: ModelFamily = .ollama
    private var generation: AnyCancellable?
//    private var cancellables = Set<AnyCancellable>()
    static let shared = OllamaService()
    
    private init() {}
    
    func fetchModels(host: String) async throws -> [String] {
        let response: ModelResponse = try await Ollama.shared.models(host: host)
        let responseModels: [ModelResponse.Model] = response.models
        var models: [String] = []
        for responseModel in responseModels {
            models.append(responseModel.name)
        }
        return models
    }
    
    func cancelGenerate() {
//        generation?.cancel()
        Ollama.shared.cancelRequest()
    }
    
    func callGenerateApi(prompt: String,
                         endpoint: Endpoint,
                         agent: Agent,
                         onMessage: @escaping (_ response: OllamaGenerateResponse) -> Void,
                         onComplete: @escaping (_ data: String?) -> Void,
                         onError: @escaping (_ error: AppError) -> Void) async throws {
        var request: OllamaGenerateRequest = OllamaGenerateRequest(model: endpoint.endpoint, prompt: prompt)
        let systemPrompt: String = agent.systemPrompt
        request.raw = agent.rawInstruct
        if request.raw ?? false {
            request.prompt = systemPrompt.replacingOccurrences(of: "{{user}}", with: prompt)
        } else {
            request.system = systemPrompt
            request.prompt = "\(systemPrompt)\n\n\(prompt)"
        }
        let options: Options = Options()
        request.options = options
        generation = try await Ollama.shared.generate(host: endpoint.host, data: request)
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
    
    func callCompletionApi(messages: [Message],
                           endpoint: Endpoint,
                           agent: Agent,
                           onMessage: @escaping (_ response: OllamaCompletionResponse) -> Void,
                           onComplete: @escaping (_ file: String?) -> Void,
                           onError: @escaping (_ error: AppError) -> Void) async throws {
        let messageContents = messages.map { $0.encode() }
        var request: OllamaCompletionRequest = OllamaCompletionRequest(model: endpoint.endpoint, messages: messageContents)
        let options: Options = Options()
        request.options = options
        generation = try await Ollama.shared.completion(host: endpoint.host, data: request)
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
