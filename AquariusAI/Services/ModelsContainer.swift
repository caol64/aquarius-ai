//
//  ModelsContainer.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/26.
//

import Foundation

class ModelsContainer {
    
    static let shared = ModelsContainer()
    private var chats: [String: Chat] = [:]
    private var messages: [String: [Message]] = [:]
    
    private init() {}
    
    func allChats() -> [Chat] {
        let chatList = Array(chats.values)
        let sortedChatList = chatList.sorted(by: { $0.createdAt < $1.createdAt })
        return sortedChatList
    }
    
    func addChat(_ chat: Chat) {
        chats[chat.id] = chat
    }
    
    func deleteChat(_ chat: Chat) {
        chats.removeValue(forKey: chat.id)
        messages.removeValue(forKey: chat.id)
    }
    
    func clearChats() {
        chats.removeAll()
    }
    
    func getMessages(_ chat: Chat) -> [Message] {
        return messages[chat.id] ?? []
    }
    
    func addMessage(_ message: Message, chat: Chat) {
        var messageList = messages[chat.id] ?? []
        messageList.append(message)
    }
    
    func deleteMessage(_ message: Message, chat: Chat) {
        var messageList = messages[chat.id]
        messageList?.removeAll(where: { $0.id == message.id })
    }
    
    func addMessages(_ messages: [Message], chat: Chat) {
        var messageList = self.messages[chat.id] ?? []
        messageList.append(contentsOf: messages)
        self.messages[chat.id] = messageList
    }
    
}
