//
//  MessageListViewModel.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

@MainActor
@Observable
final class MessageListViewModel {
    private(set) var messages: [ActionMessage] = []
    private let useCase: MessageUseCase

    init(useCase: MessageUseCase) {
        self.useCase = useCase
    }

    func load() {
        messages = (try? useCase.load()) ?? []
    }

    func addMessage(content: String) async throws {
        try await useCase.add(content: content)
        load()
    }

    func updateMessage(
        _ message: ActionMessage,
        content: String
    ) async throws {
        try await useCase.update(message, content: content)
        load()
    }

    func deleteMessage(_ message: ActionMessage) async throws {
        try await useCase.delete(message)
        load()
    }
}
