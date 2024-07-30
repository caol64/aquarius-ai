//
//  ChatService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/26.
//

import Foundation
import SwiftData

class ChatService: BaseService {
    
    static let shared = ChatService()
    
    private override init() {}
    
    func fetch() async throws -> [Chat] {
        ModelsContainer.shared.clearChats()
        let descriptor = FetchDescriptor<Chat>()
        let chats = try modelContext.fetch(descriptor)
        if !chats.isEmpty {
            for chat in chats {
                ModelsContainer.shared.addChat(chat)
                ModelsContainer.shared.addMessages(try fetchMessage(chat), chat: chat)
            }
        }
        return ModelsContainer.shared.allChats()
    }
    
    private func fetchMessage(_ chat: Chat) throws -> [Message] {
        let chatId: String = chat.id
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate<Message> { data in
                data.chatId == chatId
            },
            sortBy: [SortDescriptor(\Message.createdAt, order: .forward)]
        )
        let messages = try modelContext.fetch(descriptor)
        return messages
    }
    
    func fetchCache() -> [Chat] {
        return ModelsContainer.shared.allChats()
    }
    
    func addChat(_ chat: Chat) {
        ModelsContainer.shared.addChat(chat)
    }
    
    func fetchMessageCache(_ chat: Chat) -> [Message] {
        return ModelsContainer.shared.getMessages(chat)
    }
    
    func addMessage(_ message: Message, chat: Chat) {
        ModelsContainer.shared.addMessage(message, chat: chat)
    }
    
}
