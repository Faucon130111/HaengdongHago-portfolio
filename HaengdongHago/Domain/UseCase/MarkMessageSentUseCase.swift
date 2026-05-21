//
//  MarkMessageSentUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct MarkMessageSentUseCase {
    let messageRepo: ActionMessageRepository

    func execute(messageId: UUID, at date: Date = .now) throws {
        try messageRepo.updateLastSentAt(messageId: messageId, date: date)
    }
}
