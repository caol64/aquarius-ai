//
//  Chat.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/26.
//

import Foundation
import SwiftData

@Model
class Chat: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    
    init(name: String) {
        self.name = name
    }
}
