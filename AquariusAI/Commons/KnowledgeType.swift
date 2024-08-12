//
//  KnowledgeType.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

enum KnowledgeType: String, Codable {
    case txt
}

enum KnowledgeStatus: String, Codable {
    case inited
    case ready
    case completed
    case failed
}
