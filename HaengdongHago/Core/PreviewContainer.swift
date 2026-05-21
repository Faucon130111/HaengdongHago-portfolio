//
//  PreviewContainer.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/3/26.
//

import SwiftData

@MainActor
struct PreviewContainer {
    static let actionMessage: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: ActionMessageEntity.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            let context = container.mainContext
            for item in ActionMessage.defaults() {
                context.insert(ActionMessageEntity.from(item))
            }

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
