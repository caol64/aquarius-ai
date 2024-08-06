//
//  KnowledgeViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import Foundation
import SwiftData

@Observable
class KnowledgeViewModel: BaseService {
    var knowledges: [Knowledge] = []
    static let shared = KnowledgeViewModel()
    
    private override init() {}
    
    func fetch() async {
        let descriptor = FetchDescriptor<Knowledge>(
            sortBy: [SortDescriptor(\Knowledge.createdAt, order: .forward)]
        )
        do {
            knowledges = try modelContext.fetch(descriptor)
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
        }
    }
    
    func save(_ knowledge: Knowledge) async {
        modelContext.insert(knowledge)
        await fetch()
    }
    
    func delete(_ knowledge: Knowledge) async {
        modelContext.delete(knowledge)
        await fetch()
    }
    
}
