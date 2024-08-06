//
//  Knowledge.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import Foundation
import SwiftData

@Model
class Knowledge: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var file: String = ""
    var type: String
    var status: String
    var chunkSize: Int = 1024
    var topK: Int = 2
    var indexPath: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    
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
