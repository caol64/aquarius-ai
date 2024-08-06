//
//  KnowledgeChunk.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import Foundation
import SwiftData

@Model
class KnowledgeChunk {
    var knowledgeId: String
    var content: String
    var index: Int
    
    init(knowledgeId: String, content: String, index: Int) {
        self.knowledgeId = knowledgeId
        self.content = content
        self.index = index
    }
}
