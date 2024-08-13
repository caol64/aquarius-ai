//
//  NLEmbeddings.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/12.
//

import Foundation
import NaturalLanguage

class NLEmbeddings {
    func embedding(prompts: [String]) async throws -> [[Double]] {
        guard let embedding = NLEmbedding.sentenceEmbedding(for: .simplifiedChinese) else {
            throw AppError.bizError(description: "Failed to load the embedding model.")
        }
        var vectors: [[Double]] = []
        for prompt in prompts {
            if let vector = embedding.vector(for: prompt) {
                print("Embedding vector for \(prompt): \(vector)")
                vectors.append(vector)
            }
        }
//        for prompt in prompts {
//            let distance = embedding.distance(between: "身长七尺，细眼长髯的人是谁？", and: prompt)
//            print(distance.description)
//        }
        return vectors
    }
    
}
