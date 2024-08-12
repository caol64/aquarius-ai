//
//  KnowledgeViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import Foundation
import SwiftData

@Observable
class KnowledgeViewModel: BaseViewModel {
    var knowledges: [Knowledges] = []
    
    override init(errorBinding: ErrorBinding, modelContext: ModelContext) {
        super.init(errorBinding: errorBinding, modelContext: modelContext)
        fetch()
    }
    
    private func fetch() {
        Task {
            let descriptor = FetchDescriptor<Knowledges>(
                sortBy: [SortDescriptor(\Knowledges.createdAt, order: .forward)]
            )
            knowledges = _fetch(descriptor: descriptor)
        }
    }
    
    func onAdd() -> Knowledges {
        let knowledge = Knowledges(name: "new knowledge")
        save(knowledge)
        fetch()
        return knowledge
    }
    
    func onDelete(_ knowledge: Knowledges?) {
        if let knowledge = knowledge {
            delete(knowledge)
            fetch()
        }
    }
    
    func buildIndex(knowledge: Knowledges) {
        guard knowledge.status == .inited else {
            handleError(error: AppError.bizError(description: "Please choose the knowledge file."))
            return
        }
        guard let embedModel = knowledge.embedModel else {
            handleError(error: AppError.bizError(description: "Please setup a embedding model."))
            return
        }
        Task {
            do {
                try await knowledge.buildIndex(embedModel: embedModel)
                let savedPath = "knowleges/\(knowledge.id).db"
                try saveFileToDocumentsDirectory(knowledge.embeddings, to: savedPath)
                knowledge.indexPath = savedPath
                try saveChunks(chunks: knowledge.chunks)
                knowledge.status = .completed
            } catch {
                handleError(error: error)
            }
        }
    }
    
    func saveChunks(chunks: [KnowledgeChunks]) throws {
        try modelContext.transaction {
            for chunk in chunks {
                modelContext.insert(chunk)
            }
            try modelContext.save()
        }
    }
    
    func getChunks(knowledgeId: String, indices: [Int]) async throws -> [String] {
        let descriptor = FetchDescriptor<KnowledgeChunks>(
            predicate: #Predicate<KnowledgeChunks> { data in
                data.knowledgeId == knowledgeId
            }
        )
        // TODO: should use sql filter
        let chunks = _fetch(descriptor: descriptor)
        let result = chunks.filter {
            indices.contains($0.index)
        }
        return result.map {
            $0.content
        }
    }
    
    func ragByKnowledge(knowledge: Knowledges, embedModel: Models?, prompt: String) async throws -> String {
        if knowledge.status != .completed {
            throw AppError.bizError(description: "Knowledge is not completely configured.")
        }
        guard let embedModel = embedModel else {
            throw AppError.bizError(description: "The embedding model is not configured.")
        }
        // step1 load knowledge
        let savedPath = "knowleges/\(knowledge.id).db"
        let knowledgeVector = try loadFileFromDocumentsDirectory(savedPath, as: [[Double]].self)
        // step2 embed prompt
        let embeddings = try await embedModel.embedding(texts: [prompt])
        let promptVector = embeddings[0]
        // step3 find most similar vector
        let scores = try mostSimilarVector(queryVector: promptVector, vectors: knowledgeVector, topK: knowledge.topK)
        print(scores)
        // step4 obtain the text corresponding to the vector
        let chunks = try await getChunks(knowledgeId: knowledge.id, indices: scores.map { $0.index })
        var result = "Answer the question based only on the following context:\n---------------------\n"
        for chunk in chunks {
            result.append(chunk)
            result.append("\n")
        }
        result.append("---------------------\nQuestion: ")
        result.append(prompt)
        result.append("Answer: ")
        return result
    }
    
    func handleModelPath(knowledge: Knowledges, directory: URL) {
        knowledge.file = directory.path()
        let gotAccess = directory.startAccessingSecurityScopedResource()
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        if !gotAccess {
            handleError(error: AppError.directoryNotReadable(path: directory.path()))
        }
        do {
            knowledge.bookmark = try createBookmarkData(for: directory)
            knowledge.status = .ready
        } catch {
            handleError(error: error)
        }
    }
    
}
