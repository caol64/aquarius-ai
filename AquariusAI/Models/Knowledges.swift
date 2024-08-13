//
//  Knowledges.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import Foundation
import SwiftData

@Model
class Knowledges: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var file: String?
    var type: KnowledgeType
    var status: KnowledgeStatus
    var chunkSize: Int = 1024
    var topK: Int = 2
    var vecPath: String?
    var chunkPath: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    var embedModel: Models?
    @Transient var chunks: [String] = []
    @Transient var embeddings: [[Double]] = []
    
    init(name: String) {
        self.name = name
        self.type = .txt
        self.status = .inited
    }
}

extension Knowledges {
    func buildIndex(embedModel: Models) async throws {
        var modelDirectory: URL?
        if let data = self.bookmark {
            modelDirectory = restoreFileAccess(with: data) { data in
                self.bookmark = data
            }
        }
        guard let directory = modelDirectory else {
            throw AppError.bizError(description: "The knowledge file path is invalid.")
        }
        _ = directory.startAccessingSecurityScopedResource()
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        if !isFileReadable(path: directory.path()) {
            throw AppError.directoryNotReadable(path: directory.path())
        }
        let content = try String(contentsOf: directory, encoding: .utf8)
        self.chunks = splitTextIntoChunks(content, chunkSize: self.chunkSize)
        self.embeddings = try await embedModel.embedding(texts: chunks)
        let vecPath = "knowleges/\(self.id).vec"
        try saveFileToDocumentsDirectory(self.embeddings, to: vecPath)
        let chunkPath = "knowleges/\(self.id).chunk"
        try saveFileToDocumentsDirectory(self.chunks, to: chunkPath)
    }
}

extension Knowledges {
    func ragByKnowledge(prompt: String) async throws -> String {
        if self.status != .completed {
            throw AppError.bizError(description: "Knowledge is not completely configured.")
        }
        guard let embedModel = self.embedModel else {
            throw AppError.bizError(description: "The embedding model is not configured.")
        }
        // step1 load knowledge
        let vecPath = "knowleges/\(self.id).vec"
        self.embeddings = try loadFileFromDocumentsDirectory(vecPath, as: [[Double]].self)
        let chunkPath = "knowleges/\(self.id).chunk"
        self.chunks = try loadFileFromDocumentsDirectory(chunkPath, as: [String].self)
        // step2 embed prompt
        let embeddings = try await embedModel.embedding(texts: [prompt])
        let promptVector = embeddings[0]
        // step3 find most similar chunks
        let scores = try mostSimilarVector(queryVector: promptVector, vectors: self.embeddings, topK: self.topK)
        let chunks = scores.map { self.chunks[$0.index] }
        // step4 build prompt
        var result = "Answer the question based only on the following context:\n\n"
        for chunk in chunks {
            result.append(chunk)
            result.append("\n")
        }
        result.append("\nQuestion:\n\n")
        result.append(prompt)
        return result
    }
}
