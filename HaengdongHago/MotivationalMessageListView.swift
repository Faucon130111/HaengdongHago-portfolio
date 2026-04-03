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
    @Query(sort: \MotivationalMessage.createdAt, order: .forward) private var messages: [MotivationalMessage]
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
        .navigationTitle("동기부여 메시지")
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
        
        context.insert(MotivationalMessage(content: trimmed))
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
            .modelContainer(for: MotivationalMessage.self, inMemory: true)
    }
}
