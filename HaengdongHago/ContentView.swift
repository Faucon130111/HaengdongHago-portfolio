//
//  ContentView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/24/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var actionMessages: [ActionMessage]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(actionMessages) { message in
                    Text(message.content)
                }
                .onDelete(perform: deleteItems)
            }
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
            .toolbar {
                #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                #endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {}

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(actionMessages[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ActionMessage.self, inMemory: true)
}
