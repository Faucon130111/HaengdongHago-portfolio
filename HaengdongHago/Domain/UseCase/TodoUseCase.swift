//
//  TodoUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation

struct TodoUseCase {
    let repo: TodoRepository
    let notification: TodoNotificationScheduling

    func load() throws -> [Todo] {
        try repo.fetchAll()
    }

    func add(
        title: String,
        detail: String,
        dueDate: Date?,
        notifies: Bool
    ) async throws {
        let todo = Todo(
            title: title,
            detail: detail,
            dueDate: dueDate,
            notifies: notifies
        )
        try repo.add(todo)
        await syncNotification(for: todo)
    }

    func update(
        _ todo: Todo,
        title: String,
        detail: String,
        dueDate: Date?,
        notifies: Bool
    ) async throws {
        var updated = todo
        updated.title = title
        updated.detail = detail
        updated.dueDate = dueDate
        updated.notifies = notifies
        try repo.update(updated)
        await syncNotification(for: updated)
    }

    func toggleDone(_ todo: Todo) async throws {
        var updated = todo
        updated.isDone.toggle()
        try repo.update(updated)
        await syncNotification(for: updated)
    }

    func delete(_ todo: Todo) async throws {
        try repo.delete(todo)
        await notification.cancel(id: todo.id)
    }

    // MARK: - Private

    /// 알림 등록 규칙: 알림 ON + 미완료 + 미래 일시일 때만 등록하고, 그 외엔 취소한다.
    private func syncNotification(for todo: Todo) async {
        await notification.cancel(id: todo.id)

        guard todo.notifies,
              !todo.isDone,
              let dueDate = todo.dueDate,
              dueDate > Date()
        else {
            return
        }

        await notification.schedule(
            id: todo.id,
            title: "할 일 🔔",
            body: todo.title,
            at: dueDate
        )
    }
}
