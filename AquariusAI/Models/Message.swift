//
//  Message.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/4/28.
//

import Foundation
import SwiftData

//@Model
class Message: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var chatId: String
    var content: String
    var attachments: String = ""
    var sequence: Int
    var _role: String
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    
    init(chatId: String, content: String, sequence: Int, role: Role) {
        self.chatId = chatId
        self.content = content
        self.sequence = sequence
        self._role = role.rawValue
    }
    
    var role: Role {
        get {
            return Role(rawValue: _role)!
        }
        set {
            _role = newValue.rawValue
        }
    }
    
    func isAssistant() -> Bool {
        return role == Role.assistant
    }
    
    func isUser() -> Bool {
        return role == Role.user
    }
    
    func isSystem() -> Bool {
        return role == Role.system
    }
    
    func encode() -> [String: String] {
        return ["role": _role, "content": content]
    }
    
}
