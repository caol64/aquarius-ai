//
//  TFLanguageModelConfiguration.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/11/15.
//

import Foundation
import Hub

class TFLanguageModelConfiguration {
    struct Configurations {
        var modelConfig: Config
        var tokenizerConfig: Config?
        var tokenizerData: Config
    }
    
    let hubApi: HubApi = .shared
    var configurations: Configurations?
    public init(modelFolder: URL) {
        do {
            configurations = try loadConfig(modelFolder: modelFolder)
        } catch {
            configurations = nil
        }
    }
    
    func loadConfig(modelFolder: URL) throws -> Configurations {
        // Note tokenizerConfig may be nil (does not exist in all models)
        let modelConfig = try hubApi.configuration(fileURL: modelFolder.appending(path: "config.json"))
        let tokenizerConfig = try hubApi.configuration(fileURL: modelFolder.appending(path: "tokenizer_config.json"))
        let tokenizerVocab = try hubApi.configuration(fileURL: modelFolder.appending(path: "tokenizer.json"))
        
        let configs = Configurations(
            modelConfig: modelConfig,
            tokenizerConfig: updateTokenizerConfig(tokenizerConfig),
            tokenizerData: tokenizerVocab
        )
        return configs
    }
    
    public var modelConfig: Config {
        get {
            configurations!.modelConfig
        }
    }

    public var tokenizerConfig: Config? {
        get throws {
            if let hubConfig = configurations!.tokenizerConfig {
                // Try to guess the class if it's not present and the modelType is
                if let _ = hubConfig.tokenizerClass?.stringValue { return hubConfig }
                guard let modelType = modelType else { return hubConfig }

                // If the config exists but doesn't contain a tokenizerClass, use a fallback config if we have it
                if let fallbackConfig = Self.fallbackTokenizerConfig(for: modelType) {
                    let configuration = fallbackConfig.dictionary.merging(hubConfig.dictionary, uniquingKeysWith: { current, _ in current })
                    return Config(configuration)
                }

                // Guess by capitalizing
                var configuration = hubConfig.dictionary
                configuration["tokenizer_class"] = "\(modelType.capitalized)Tokenizer"
                return Config(configuration)
            }

            // Fallback tokenizer config, if available
            guard let modelType = modelType else { return nil }
            return Self.fallbackTokenizerConfig(for: modelType)
        }
    }

    public var tokenizerData: Config {
        get {
            configurations!.tokenizerData
        }
    }

    public var modelType: String? {
        get {
            modelConfig.modelType?.stringValue
        }
    }
    
    static func fallbackTokenizerConfig(for modelType: String) -> Config? {
//        guard let url = Bundle.module.url(forResource: "\(modelType)_tokenizer_config", withExtension: "json") else { return nil }
//        do {
//            let data = try Data(contentsOf: url)
//            let parsed = try JSONSerialization.jsonObject(with: data, options: [])
//            guard let dictionary = parsed as? [String: Any] else { return nil }
//            return Config(dictionary)
//        } catch {
//            return nil
//        }
        return nil
    }
    
    private func updateTokenizerConfig(_ tokenizerConfig: Config) -> Config {
        // workaround: replacement tokenizers for unhandled values in swift-transform
        if let tokenizerClass = tokenizerConfig.tokenizerClass?.stringValue,
            let replacement = replacementTokenizers[tokenizerClass]
        {
            var dictionary = tokenizerConfig.dictionary
            dictionary["tokenizer_class"] = replacement
            return Config(dictionary)
        }

        return tokenizerConfig
    }
}

public class TokenizerReplacementRegistry: @unchecked Sendable {

    // Note: using NSLock as we have very small (just dictionary get/set)
    // critical sections and expect no contention.  this allows the methods
    // to remain synchronous.
    private let lock = NSLock()

    /// overrides for TokenizerModel/knownTokenizers
    private var replacementTokenizers = [
        "InternLM2Tokenizer": "PreTrainedTokenizer",
        "Qwen2Tokenizer": "PreTrainedTokenizer",
        "CohereTokenizer": "PreTrainedTokenizer",
    ]

    public subscript(key: String) -> String? {
        get {
            lock.withLock {
                replacementTokenizers[key]
            }
        }
        set {
            lock.withLock {
                replacementTokenizers[key] = newValue
            }
        }
    }
}

public let replacementTokenizers = TokenizerReplacementRegistry()
