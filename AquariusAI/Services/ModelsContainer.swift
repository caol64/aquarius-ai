//
//  ModelsContainer.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/26.
//

import Foundation

class ModelsContainer {
    
    static let shared = ModelsContainer()
    private var chats: [String: Chats] = [:]
    private var messages: [String: [Messages]] = [:]
    
    private init() {}
    
    func allChats() -> [Chats] {
        let chatList = Array(chats.values)
        let sortedChatList = chatList.sorted(by: { $0.createdAt < $1.createdAt })
        return sortedChatList
    }
    
    func addChat(_ chat: Chats) {
        chats[chat.id] = chat
    }
    
    func deleteChat(_ chat: Chats) {
        chats.removeValue(forKey: chat.id)
        messages.removeValue(forKey: chat.id)
    }
    
    func clearChats() {
        chats.removeAll()
    }
    
    func getMessages(_ chat: Chats) -> [Messages] {
        return messages[chat.id] ?? []
    }
    
    func addMessage(_ message: Messages, chat: Chats) {
        var messageList = messages[chat.id] ?? []
        messageList.append(message)
    }
    
    func deleteMessage(_ message: Messages, chat: Chats) {
        var messageList = messages[chat.id]
        messageList?.removeAll(where: { $0.id == message.id })
    }
    
    func addMessages(_ messages: [Messages], chat: Chats) {
        var messageList = self.messages[chat.id] ?? []
        messageList.append(contentsOf: messages)
        self.messages[chat.id] = messageList
    }
    
}
