//
//  ActionMessage.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/26/26.
//

import SwiftData
import Foundation

@Model
final class ActionMessage {
    var id: UUID
    var content: String
    var createdAt: Date
    var isActivate: Bool
    
    init(
        content: String,
        isActivate: Bool = true,
    ) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.isActivate = isActivate
    }
}

extension ActionMessage {
    static func defaults() -> [ActionMessage] {
        [
            ActionMessage(content: "행동하지 않으면 아무것도 일어나지 않는다"),
            ActionMessage(content: "100점짜리 하루보다 70점짜리 7일이 낫다"),
            ActionMessage(content: "준비가 됐을 때 시작하는 사람은 영원히 시작 못 한다"),
            ActionMessage(content: "완벽한 타이밍은 없다. 지금이 가장 빠른 타이밍이다"),
        ]
    }
    
    static func random(from messages: [ActionMessage]) -> ActionMessage? {
        messages.filter { $0.isActivate }.randomElement()
    }
}
