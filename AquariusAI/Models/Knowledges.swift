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
    var type: String
    var status: String
    var chunkSize: Int = 1024
    var topK: Int = 2
    var indexPath: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    @Transient var embedModel: Models?
    @Transient var chunks: [KnowledgeChunks] = []
    @Transient var embeddings: [[Double]] = []
    
    init(name: String) {
        self.name = name
        self.type = KnowledgeType.txt.rawValue
        self.status = KnowledgeStatus.inited.rawValue
    }
    
    var knowledgeType: KnowledgeType {
        get {
            return KnowledgeType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }
    
    var knowledgeStatus: KnowledgeStatus {
        get {
            return KnowledgeStatus(rawValue: status)!
        }
        set {
            status = newValue.rawValue
        }
    }
}

extension Knowledges {
    func buildIndex(embedModel: Models) async throws {
        let startTime = Date()
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
        if !isFileReadable(path: directory.path()) {
            throw AppError.directoryNotReadable(path: directory.path())
        }
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        let content = try String(contentsOf: directory, encoding: .utf8)
        let chunks = splitTextIntoChunks(content, chunkSize: self.chunkSize)
        self.embeddings = try await OllamaService.shared.callEmbeddingApi(prompts: chunks, model: embedModel)
        var knowledgeChunks: [KnowledgeChunks] = []
        for (i, chunk) in chunks.enumerated() {
            let knowledgeChunk = KnowledgeChunks(knowledgeId: self.id, content: chunk, index: i)
            knowledgeChunks.append(knowledgeChunk)
        }
        self.chunks = knowledgeChunks
    }
}
