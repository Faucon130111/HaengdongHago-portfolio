//
//  SwiftDataActionMessageRepository.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation
import SwiftData

final class SwiftDataActionMessageRepository: ActionMessageRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [ActionMessage] {
        let entities = try context.fetch(
            FetchDescriptor<ActionMessageEntity>(sortBy: [SortDescriptor(\.order)])
        )
        return entities.map { $0.toDomain() }
    }

    func fetchCount() throws -> Int {
        try context.fetchCount(FetchDescriptor<ActionMessageEntity>())
    }

    func add(_ message: ActionMessage) throws {
        context.insert(ActionMessageEntity.from(message))
        try context.save()
    }

    func update(_ message: ActionMessage) throws {
        let id = message.id
        let descriptor = FetchDescriptor<ActionMessageEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.content = message.content
        entity.order = message.order
        entity.lastSentAt = message.lastSentAt
        try context.save()
    }

    func delete(_ message: ActionMessage) throws {
        let id = message.id
        let descriptor = FetchDescriptor<ActionMessageEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = try context.fetch(descriptor).first else { return }
        context.delete(entity)
        try context.save()
    }

    func updateLastSentAt(
        messageId: UUID,
        date: Date
    ) throws {
        let descriptor = FetchDescriptor<ActionMessageEntity>(
            predicate: #Predicate { $0.id == messageId }
        )
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.lastSentAt = date
        try context.save()
    }
}
