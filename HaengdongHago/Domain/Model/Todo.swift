//
//  Todo.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation

// MARK: - 할 일

struct Todo: Identifiable {
    var id: UUID
    var title: String
    var detail: String
    var dueDate: Date?
    var notifies: Bool
    var isDone: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        dueDate: Date? = nil,
        notifies: Bool = false,
        isDone: Bool = false,
        createdAt: Date = Date()
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

extension Todo {
    static func samples() -> [Todo] {
        [
            Todo(
                title: "운동 30분",
                detail: "스쿼트 + 가벼운 러닝",
                dueDate: Date().addingTimeInterval(3600),
                notifies: true
            ),
            Todo(
                title: "아토믹 해빗 1챕터 읽기",
                detail: "자기 전 10페이지"
            ),
            Todo(
                title: "장보기",
                isDone: true
            ),
        ]
    }
}
