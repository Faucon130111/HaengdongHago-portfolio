//
//  MotivationalMessageListView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/3/26.
//

import SwiftUI
import SwiftData

struct MotivationalMessageListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ActionMessage.createdAt, order: .forward) private var messages: [ActionMessage]
    @State private var newMessage = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        List {
            ForEach(messages) { message in
                Text(message.content)
            }
            .onDelete(perform: deleteMessages)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                TextField("새 항목", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                Button("추가") {
                    addMessage()
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle("행동 메시지")
        .toolbar {
            EditButton()
        }
    }
    
    private func addMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty
        else {
            return
        }
        
        context.insert(ActionMessage(content: trimmed))
        newMessage = ""
        isFocused = false
    }
    
    private func deleteMessages(at offsets: IndexSet) {
        for index in offsets {
            context.delete(messages[index])
        }
    }
}

#Preview {
    NavigationStack {
        MotivationalMessageListView()
            .modelContainer(for: ActionMessage.self, inMemory: true)
    }
}
