//
//  OllamaService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/10.
//

import Combine

class OllamaService {
    
    private let modelFamily: ModelFamily = .ollama
    private var instance: Ollama?
    private var generation: AnyCancellable?
    
    static let shared = OllamaService()
    
    private init() {}
    
    func fetchModels(host: String) async throws -> [String] {
        let response: ModelResponse = try await Ollama(host).models()
        let responseModels: [ModelResponse.Model] = response.models
        var models: [String] = []
        for responseModel in responseModels {
            models.append(responseModel.name)
        }
        return models
    }
    
    func cancelGenerate() {
        generation?.cancel()
        instance?.cancelRequest()
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
        instance = Ollama(endpoint.host)
        generation = try await instance!.generate(data: request)
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
        instance = Ollama(endpoint.host)
        generation = try await instance!.completion(data: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    onComplete(nil)
                case .failure(let error):
                    onError(AppError.networkError(description: error.localizedDescription))
                }
            }, receiveValue: { response in
//                generalResponse.response = response.message?.content
                onMessage(response)
            })
    }
    
}
