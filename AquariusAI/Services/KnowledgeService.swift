//
//  KnowledgeService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import Foundation

class KnowledgeService {
    static let shared = KnowledgeService()
    
    private init() {}
    
    func buildIndex(knowledge: Knowledge, endpoint: Endpoint) async throws {
        let startTime = Date()
        var modelDirectory: URL?
        if let data = knowledge.bookmark {
            modelDirectory = restoreFileAccess(with: data) { data in
                knowledge.bookmark = data
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
        let chunks = splitTextIntoChunks(content, chunkSize: knowledge.chunkSize)
        let embeddings: [[Double]] = try await OllamaService.shared.callEmbeddingApi(prompts: chunks, endpoint: endpoint)
        let savedPath = "knowleges/\(knowledge.id).db"
        try saveFileToDocumentsDirectory(embeddings, to: savedPath)
        knowledge.indexPath = savedPath
        knowledge.knowledgeStatus = .completed
    }
    
    private func splitTextIntoChunks(_ text: String, chunkSize: Int) -> [String] {
        var chunks: [String] = []
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        var length = 0
        var start = 0
        for (i, line) in zip(lines.indices, lines) {
            if length + line.count > chunkSize {
                let array = lines[start...i-1]
                chunks.append(array.joined(separator: "\n"))
                start = i
                length = 0
            }
            if i == lines.count - 1 {
                let array = lines[start...i]
                chunks.append(array.joined(separator: "\n"))
            }
            length += line.count
        }
        return chunks
    }
    
}
