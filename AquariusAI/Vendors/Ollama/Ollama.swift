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
    private var baseURL: URL
    private var streamRequest: DataStreamRequest?
    private var decoder: JSONDecoder {
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
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        return encoder
    }
    private var headers: HTTPHeaders {
        ["Content-Type": "application/json"]
    }
    
    init(_ baseURL: String) {
        self.baseURL = URL(string: baseURL)!
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
}

// MARK: - models
extension Ollama {
    
    func models() async throws -> ModelResponse {
        let request = AF.request(baseURL.appendingPathComponent("/api/tags")).validate()
        let response = request.serializingDecodable(ModelResponse.self, decoder: decoder)
        
        return try await response.value
    }
}

// MARK: - generate
extension Ollama {

    func generate(data: OllamaGenerateRequest) async throws -> AnyPublisher<OllamaGenerateResponse, AFError> {
        let subject = PassthroughSubject<OllamaGenerateResponse, AFError>()
        let request = AF.streamRequest(baseURL.appendingPathComponent("/api/generate"),
                                       method: .post,
                                       headers: headers) { urlRequest in
            urlRequest.httpBody = try self.encoder.encode(data)
        }.validate()
        
        streamRequest = request.responseStreamDecodable(of: OllamaGenerateResponse.self, using: decoder) { stream in
            switch stream.event {
            case .stream(let result):
                switch result {
                case .success(let response):
                    subject.send(response)
                case .failure(let error):
                    subject.send(completion: .failure(error))
                }
            case .complete(_):
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
}

// MARK: - completion
extension Ollama {

    func completion(data: OllamaCompletionRequest) async throws -> AnyPublisher<OllamaCompletionResponse, AFError> {
        let subject = PassthroughSubject<OllamaCompletionResponse, AFError>()
        let request = AF.streamRequest(baseURL.appendingPathComponent("/api/chat"),
                                       method: .post,
                                       headers: headers) { urlRequest in
            urlRequest.httpBody = try self.encoder.encode(data)
        }.validate()
        
        streamRequest = request.responseStreamDecodable(of: OllamaCompletionResponse.self, using: decoder) { stream in
            switch stream.event {
            case .stream(let result):
                switch result {
                case .success(let response):
                    subject.send(response)
                case .failure(let error):
                    subject.send(completion: .failure(error))
                }
            case .complete(_):
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
}

// MARK: - cancelRequest
extension Ollama {
    
    func cancelRequest() {
        streamRequest?.cancel()
    }
}

// MARK: - Responses and Requests
struct ModelResponse: Decodable {
    let models: [Model]
    
    struct Model: Decodable {
        let name: String
        let digest: String
        let size: Int
        //        let modifiedAt: Date
    }
}

struct OllamaGenerateRequest: Encodable {
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
    var keep_alive: String?
    
    init(model: String, prompt: String, stream: Bool = true) {
        self.model = model
        self.prompt = prompt
        self.stream = stream
    }
}

struct OllamaCompletionRequest: Encodable {
    var model: String
    var messages: [[String: String]]
    var format: Format?
    var options: Options?
    var stream: Bool
    var keep_alive: String?
    
    init(model: String, messages: [[String: String]], stream: Bool = true) {
        self.model = model
        self.messages = messages
        self.stream = stream
    }
    
}

struct OllamaGenerateResponse: Decodable {
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

struct OllamaCompletionResponse: Decodable {
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

struct Options: Encodable {
    var mirostat: Int?
    var mirostatEta: Double?
    var mirostatTau: Double?
    var numCtx: Int = 8192
    var numBatch: Int?
    var numGqa: Int?
    var numGpu: Int?
    var mainGpu: Int?
    var numThread: Int?
    var repeatLastN: Int?
    var repeatPenalty: Int?
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


