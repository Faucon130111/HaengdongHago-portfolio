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
        let container = try! ModelContainer(
            for: ActionMessage.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let context = container.mainContext
        ActionMessage.defaults().forEach {
            context.insert($0)
        }
        
        return container
    }()
    
}
