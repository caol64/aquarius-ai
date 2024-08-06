//
//  Ollama.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/4/25.
//
import Foundation
import Alamofire
import Combine

class Ollama {
    private let headers: HTTPHeaders = ["Content-Type": "application/json"]
    private let encoder: JSONEncoder = encoder()
    private let decoder: JSONDecoder = decoder()
    static let shared = Ollama()
    
    private init() {}
    
    private static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    private static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }
}

// MARK: - Basic request function
extension Ollama {
    
    private func makeStreamRequest<T: Decodable, R: Encodable>(requestData: R, host: String, path: String) async throws -> AnyPublisher<T, AFError> {
        let url = URL(string: host)!.appendingPathComponent(path)
        let subject = PassthroughSubject<T, AFError>()
        let request = AF.streamRequest(url, method: .post, headers: headers) { urlRequest in
            urlRequest.httpBody = try self.encoder.encode(requestData)
        }.validate()
        
        let _: DataStreamRequest = request.responseStreamDecodable(of: T.self, using: decoder) { stream in
            switch stream.event {
            case .stream(let result):
                switch result {
                case .success(let response):
                    subject.send(response)
                case .failure(let error):
                    subject.send(completion: .failure(error))
                }
            case .complete(let completion):
                if let error = completion.error {
                    subject.send(completion: .failure(error))
                } else {
                    subject.send(completion: .finished)
                }
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    private func makeRequest<T: Decodable, R: Encodable>(requestData: R, host: String, path: String) async throws -> T {
        let url = URL(string: host)!.appendingPathComponent(path)
        let request = AF.request(url, method: .post, headers: headers) { urlRequest in
            urlRequest.httpBody = try self.encoder.encode(requestData)
        }.validate()
        
        return try await withCheckedThrowingContinuation { continuation in
            request.responseData { response in
                switch response.result {
                case .success(let data):
                    do {
//                        if let jsonString = String(data: data, encoding: .utf8) {
//                            print("Response JSON String: \(jsonString)")
//                        }
                        let decodedResponse = try self.decoder.decode(T.self, from: data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - List Local Models
extension Ollama {
    func models(host: String) async throws -> ModelResponse {
        let url = URL(string: host)!.appendingPathComponent("/api/tags")
        let request = AF.request(url).validate()
        let response = request.serializingDecodable(ModelResponse.self, decoder: decoder)
        return try await response.value
    }
    
    struct ModelResponse: Decodable {
        let models: [Model]
        
        struct Model: Decodable {
            let name: String
            let digest: String
            let size: Int
            //        let modifiedAt: Date
        }
    }
}

// MARK: - Generate a completion
extension Ollama {
    func generate(host: String, data: GenerateRequest) async throws -> AnyPublisher<GenerateResponse, AFError> {
        return try await makeStreamRequest(requestData: data, host: host, path: "/api/generate")
    }
    
    struct GenerateRequest: Encodable {
        var model: String
        var prompt: String
        var images: [String]?
        var format: Format?
        var options: Options?
        var system: String?
        var template: String?
        var context: [Int]?
        var stream: Bool
        var raw: Bool?
        var keepAlive: String?
        
        init(model: String, prompt: String, stream: Bool = true) {
            self.model = model
            self.prompt = prompt
            self.stream = stream
        }
    }
    
    struct GenerateResponse: Decodable {
        let model: String
        let totalDuration: Int?
        let loadDuration: Int?
        let promptEvalCount: Int?
        let promptEvalDuration: Int?
        let evalCount: Int?
        let evalDuration: Int?
        let context: [Int]?
        let response: String
        let createdAt: Date
        let done: Bool
    }
    
    struct Options: Encodable {
        var mirostat: Int?
        var mirostatEta: Double?
        var mirostatTau: Double?
        var numCtx: Int = 2048
        var numBatch: Int?
        var numGqa: Int?
        var numGpu: Int?
        var mainGpu: Int?
        var numThread: Int?
        var repeatLastN: Int?
        var repeatPenalty: Double?
        var temperature: Double?
        var seed: Int?
        var tfsZ: Double?
        var numPredict: Int?
        var topK: Int?
        var topP: Double?
        var numKeep: Int?
        var typicalP: Double?
        var frequencyPenalty: Double?
        var penalizeNewline: Bool?
        var stop: [String]?
        var numa: Bool?
        var lowVram: Bool?
        var f16Kv: Bool?
        var vocabOnly: Bool?
        var useMmap: Bool?
        var useMlock: Bool?
    }
    
    enum Format: String, Encodable {
        case json
    }
}

// MARK: - Generate a chat completion
extension Ollama {
    func completion(host: String, data: CompletionRequest) async throws -> AnyPublisher<CompletionResponse, AFError> {
        return try await makeStreamRequest(requestData: data, host: host, path: "/api/chat")
    }
    
    struct CompletionRequest: Encodable {
        var model: String
        var messages: [[String: String]]
        var format: Format?
        var options: Options?
        var stream: Bool
        var keepAlive: String?
        
        init(model: String, messages: [[String: String]], stream: Bool = true) {
            self.model = model
            self.messages = messages
            self.stream = stream
        }
    }

    struct CompletionResponse: Decodable {
        let model: String
        let createdAt: Date
        let message: Message?
        let done: Bool
        let totalDuration: Int?
        let loadDuration: Int?
        let promptEvalCount: Int?
        let promptEvalDuration: Int?
        let evalCount: Int?
        let evalDuration: Int?
        
        struct Message: Decodable {
            let role: String
            let content: String
            let images: [String]?
        }
    }
}

// MARK: - Generate Embedding
extension Ollama {
    func embeddings(host: String, data: EmbeddingRequest) async throws -> EmbeddingResponse {
        return try await makeRequest(requestData: data, host: host, path: "/api/embed")
    }
    
    struct EmbeddingRequest: Encodable {
        let model: String
        var input: [String]
        var options: Options?
        var keepAlive: String?
    }
    
    struct EmbeddingResponse: Decodable {
        let model: String
        let embeddings: [[Double]]
    }
}

// MARK: - Cancel Request
extension Ollama {
    func cancelRequest() {
        AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
}
