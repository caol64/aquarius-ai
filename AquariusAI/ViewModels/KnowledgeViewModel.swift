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
    var isBuilding = false
    
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
        guard knowledge.status != .inited else {
            handleError(error: AppError.bizError(description: "Please choose the knowledge file."))
            return
        }
        guard let embedModel = knowledge.embedModel else {
            handleError(error: AppError.bizError(description: "Please setup an embedding model."))
            return
        }
        Task {
            isBuilding = true
            defer {
                isBuilding = false
            }
            do {
                try await knowledge.buildIndex(embedModel: embedModel)
                knowledge.status = .completed
            } catch {
                handleError(error: error)
            }
        }
    }
    
    func handleModelPath(knowledge: Knowledges, directory: URL) {
        knowledge.file = directory.path()
        knowledge.name = directory.lastPathComponent
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
