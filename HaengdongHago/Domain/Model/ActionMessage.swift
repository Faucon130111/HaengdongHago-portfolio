//
//  ActionMessage.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/26/26.
//

import Foundation

// MARK: - 발송 방식

enum DeliveryMode: String, Codable {
    case random
    case sequential
}

// MARK: - 행동 메시지

struct ActionMessage: Identifiable {
    var id: UUID
    var content: String
    var order: Int
    var lastSentAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        content: String,
        order: Int,
        lastSentAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.order = order
        self.lastSentAt = lastSentAt
        self.createdAt = createdAt
    }
}

extension ActionMessage {
    static func defaults() -> [ActionMessage] {
        [
            ActionMessage(
                content: "행동하지 않으면 아무것도 일어나지 않는다",
                order: 0
            ),
            ActionMessage(
                content: "100점짜리 하루보다 70점짜리 7일이 낫다",
                order: 1
            ),
            ActionMessage(
                content: "준비가 됐을 때 시작하는 사람은 영원히 시작 못 한다",
                order: 2
            ),
            ActionMessage(
                content: "완벽한 타이밍은 없다. 지금이 가장 빠른 타이밍이다",
                order: 3
            ),
        ]
    }
}
