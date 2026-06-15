//
//  SwiftDataTodoRepository.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation
import SwiftData

final class SwiftDataTodoRepository: TodoRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Todo] {
        let entities = try context.fetch(
            FetchDescriptor<TodoEntity>(sortBy: [SortDescriptor(\.createdAt)])
        )
        return entities.map { $0.toDomain() }
    }

    func add(_ todo: Todo) throws {
        context.insert(TodoEntity.from(todo))
        try context.save()
    }

    func update(_ todo: Todo) throws {
        let id = todo.id
        let descriptor = FetchDescriptor<TodoEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.title = todo.title
        entity.detail = todo.detail
        entity.dueDate = todo.dueDate
        entity.notifies = todo.notifies
        entity.isDone = todo.isDone
        try context.save()
    }

    func delete(_ todo: Todo) throws {
        let id = todo.id
        let descriptor = FetchDescriptor<TodoEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = try context.fetch(descriptor).first else { return }
        context.delete(entity)
        try context.save()
    }
}
