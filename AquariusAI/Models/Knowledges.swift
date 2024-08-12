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
    var indexPath: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    var embedModel: Models?
    @Transient var chunks: [KnowledgeChunks] = []
    @Transient var embeddings: [[Double]] = []
    
    init(name: String) {
        self.name = name
        self.type = .txt
        self.status = .inited
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
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        if !isFileReadable(path: directory.path()) {
            throw AppError.directoryNotReadable(path: directory.path())
        }
        let content = try String(contentsOf: directory, encoding: .utf8)
        let chunks = splitTextIntoChunks(content, chunkSize: self.chunkSize)
        self.embeddings = try await embedModel.embedding(texts: chunks)
        var knowledgeChunks: [KnowledgeChunks] = []
        for (i, chunk) in chunks.enumerated() {
            let knowledgeChunk = KnowledgeChunks(knowledgeId: self.id, content: chunk, index: i)
            knowledgeChunks.append(knowledgeChunk)
        }
        self.chunks = knowledgeChunks
    }
}
