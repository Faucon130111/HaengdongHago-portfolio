//
//  TodoEntity.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation
import SwiftData

@Model
final class TodoEntity {
    var id: UUID
    var title: String
    var detail: String
    var dueDate: Date?
    var notifies: Bool
    var isDone: Bool
    var createdAt: Date

    init(
        id: UUID,
        title: String,
        detail: String,
        dueDate: Date? = nil,
        notifies: Bool,
        isDone: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.dueDate = dueDate
        self.notifies = notifies
        self.isDone = isDone
        self.createdAt = createdAt
    }
}

extension TodoEntity {
    func toDomain() -> Todo {
        Todo(
            id: id,
            title: title,
            detail: detail,
            dueDate: dueDate,
            notifies: notifies,
            isDone: isDone,
            createdAt: createdAt
        )
    }

    static func from(_ domain: Todo) -> TodoEntity {
        TodoEntity(
            id: domain.id,
            title: domain.title,
            detail: domain.detail,
            dueDate: domain.dueDate,
            notifies: domain.notifies,
            isDone: domain.isDone,
            createdAt: domain.createdAt
        )
    }
}
