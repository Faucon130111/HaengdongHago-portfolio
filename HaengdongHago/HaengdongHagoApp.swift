//
//  HaengdongHagoApp.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/24/26.
//

import SwiftUI
import SwiftData

@main
struct HaengdongHagoApp: App {
    @State private var showSplash = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MotivationalMessage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
            .task {
                await seedDefaultsIfNeeded()
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    @MainActor
    private func seedDefaultsIfNeeded() async {
        let context = sharedModelContainer.mainContext
        
        let descriptor = FetchDescriptor<MotivationalMessage>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        
        guard count == 0 else {
            return
        }
        
        MotivationalMessage.defaults().forEach { message in
            context.insert(message)
        }
        
        try? context.save()
    }
}
