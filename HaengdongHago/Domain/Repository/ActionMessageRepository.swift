//
//  ActionMessageRepository.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation

protocol ActionMessageRepository {
    func fetchAll() throws -> [ActionMessage]
    func fetchCount() throws -> Int
    func add(_ message: ActionMessage) throws
    func update(_ message: ActionMessage) throws
    func delete(_ message: ActionMessage) throws
    func updateLastSentAt(
        messageId: UUID,
        date: Date
    ) throws
    func save() throws
}
