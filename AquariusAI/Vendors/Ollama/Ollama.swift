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
    private var isCanceled = false
    private let headers: HTTPHeaders = ["Content-Type": "application/json"]
    private let encoder: JSONEncoder = _encoder()
    private let decoder: JSONDecoder = _decoder()
    static let shared = Ollama()
    
    private init() {
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    private static func _encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    private static func _decoder() -> JSONDecoder {
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
    
    private func makeStreamRequest<T: Decodable, R: Encodable>(requestData: R, host: String, path: String) async throws -> AnyPublisher<T, AFError> {
        let url = URL(string: host)!.appendingPathComponent(path)
        let subject = PassthroughSubject<T, AFError>()
        let request = AF.streamRequest(url,
                                       method: .post,
                                       headers: headers) { urlRequest in
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
            case .complete(_):
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
}

// MARK: - models
extension Ollama {
    func models(host: String) async throws -> ModelResponse {
        let url = URL(string: host)!.appendingPathComponent("/api/tags")
        let request = AF.request(url).validate()
        let response = request.serializingDecodable(ModelResponse.self, decoder: decoder)
        return try await response.value
    }
}

// MARK: - generate
extension Ollama {
    func generate(host: String, data: OllamaGenerateRequest) async throws -> AnyPublisher<OllamaGenerateResponse, AFError> {
        return try await makeStreamRequest(requestData: data, host: host, path: "/api/generate")
    }
}

// MARK: - completion
extension Ollama {
    func completion(host: String, data: OllamaCompletionRequest) async throws -> AnyPublisher<OllamaCompletionResponse, AFError> {
        return try await makeStreamRequest(requestData: data, host: host, path: "/api/chat")
    }
}

// MARK: - cancelRequest
extension Ollama {
    func cancelRequest() {
        AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
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


