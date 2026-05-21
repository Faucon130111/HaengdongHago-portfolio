//
//  ActionMessageEntity.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation
import SwiftData

@Model
final class ActionMessageEntity {
    var id: UUID
    var content: String
    var order: Int
    var lastSentAt: Date?
    var createdAt: Date

    init(id: UUID, content: String, order: Int, lastSentAt: Date? = nil, createdAt: Date) {
        self.id = id
        self.content = content
        self.order = order
        self.lastSentAt = lastSentAt
        self.createdAt = createdAt
    }
}

extension ActionMessageEntity {
    func toDomain() -> ActionMessage {
        ActionMessage(
            id: id,
            content: content,
            order: order,
            lastSentAt: lastSentAt,
            createdAt: createdAt
        )
    }

    static func from(_ domain: ActionMessage) -> ActionMessageEntity {
        ActionMessageEntity(
            id: domain.id,
            content: domain.content,
            order: domain.order,
            lastSentAt: domain.lastSentAt,
            createdAt: domain.createdAt
        )
    }
}
