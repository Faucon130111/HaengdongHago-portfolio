//
//  MessageUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct MessageUseCase {
    let messageRepo: ActionMessageRepository
    let reschedule: RescheduleNotificationsUseCase

    func load() throws -> [ActionMessage] {
        try messageRepo.fetchAll()
    }

    func add(content: String) async throws {
        let messages = try messageRepo.fetchAll()
        let nextOrder = (messages.last?.order ?? -1) + 1
        let message = ActionMessage(content: content, order: nextOrder)
        try messageRepo.add(message)
        try await reschedule.execute()
    }

    func update(_ message: ActionMessage, content: String) async throws {
        var updated = message
        updated.content = content
        try messageRepo.update(updated)
        try await reschedule.execute()
    }

    func delete(_ message: ActionMessage) async throws {
        try messageRepo.delete(message)
        try await reschedule.execute()
    }
}
