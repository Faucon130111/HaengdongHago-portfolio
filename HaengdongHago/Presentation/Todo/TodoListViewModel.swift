//
//  TodoListViewModel.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation

@MainActor
@Observable
final class TodoListViewModel {
    private(set) var todos: [Todo] = []
    private let useCase: TodoUseCase

    init(useCase: TodoUseCase) {
        self.useCase = useCase
    }

    func load() {
        todos = ((try? useCase.load()) ?? []).sorted(by: Self.ordering)
    }

    func addTodo(
        title: String,
        detail: String,
        dueDate: Date?,
        notifies: Bool
    ) async throws {
        try await useCase.add(
            title: title,
            detail: detail,
            dueDate: dueDate,
            notifies: notifies
        )
        load()
    }

    func updateTodo(
        _ todo: Todo,
        title: String,
        detail: String,
        dueDate: Date?,
        notifies: Bool
    ) async throws {
        try await useCase.update(
            todo,
            title: title,
            detail: detail,
            dueDate: dueDate,
            notifies: notifies
        )
        load()
    }

    func toggleDone(_ todo: Todo) async throws {
        try await useCase.toggleDone(todo)
        load()
    }

    func deleteTodo(_ todo: Todo) async throws {
        try await useCase.delete(todo)
        load()
    }

    // MARK: - 정렬: 미완료 먼저(마감 빠른 순, 없으면 뒤) → 완료는 맨 아래

    private static func ordering(_ lhs: Todo, _ rhs: Todo) -> Bool {
        if lhs.isDone != rhs.isDone {
            return !lhs.isDone
        }

        switch (lhs.dueDate, rhs.dueDate) {
        case let (leftDate?, rightDate?) where leftDate != rightDate:
            return leftDate < rightDate
        case (nil, _?):
            return false
        case (_?, nil):
            return true
        default:
            return lhs.createdAt < rhs.createdAt
        }
    }
}
