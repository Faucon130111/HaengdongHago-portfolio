//
//  MessageUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct MessageUseCase {
    let messageRepo: ActionMessageRepository

    func load() throws -> [ActionMessage] {
        try messageRepo.fetchAll()
    }

    func add(content: String) throws {
        let messages = try messageRepo.fetchAll()
        let nextOrder = (messages.last?.order ?? -1) + 1
        let message = ActionMessage(content: content, order: nextOrder)
        try messageRepo.add(message)
        try messageRepo.save()
    }

    func update(_ message: ActionMessage, content: String) throws {
        var updated = message
        updated.content = content
        try messageRepo.update(updated)
        try messageRepo.save()
    }

    func delete(_ message: ActionMessage) throws {
        try messageRepo.delete(message)
        try messageRepo.save()
    }
}
