//
//  MessageListViewModel.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

@Observable
final class MessageListViewModel {
    private(set) var messages: [ActionMessage] = []
    private let useCase: MessageUseCase

    init(messageRepo: ActionMessageRepository) {
        useCase = MessageUseCase(messageRepo: messageRepo)
    }

    func load() {
        messages = (try? useCase.load()) ?? []
    }

    func addMessage(content: String) throws {
        try useCase.add(content: content)
        load()
        NotificationCenter.default.post(name: .messageListDidChange, object: nil)
    }

    func updateMessage(
        _ message: ActionMessage,
        content: String
    ) throws {
        try useCase.update(message, content: content)
        load()
        NotificationCenter.default.post(name: .messageListDidChange, object: nil)
    }

    func deleteMessage(_ message: ActionMessage) throws {
        try useCase.delete(message)
        load()
        NotificationCenter.default.post(name: .messageListDidChange, object: nil)
    }
}
