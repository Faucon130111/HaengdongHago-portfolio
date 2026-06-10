//
//  TodoListSection.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import SwiftUI

struct TodoListSection: View {
    let todos: [Todo]
    let onEdit: (Todo) -> Void
    let onToggleDone: (Todo) -> Void
    let onDelete: (Todo) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("할 일 목록")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            if todos.isEmpty {
                EmptyTodoView()
                    .frame(maxHeight: .infinity)
            } else {
                VStack(spacing: 8) {
                    ForEach(todos) { todo in
                        TodoRowView(
                            todo: todo,
                            onTap: { onEdit(todo) },
                            onToggleDone: { onToggleDone(todo) },
                            onDelete: { onDelete(todo) }
                        )
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Private

private struct EmptyTodoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("0")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(Color(.systemGray4))
                .kerning(-3)

            Rectangle()
                .fill(Color(.systemGray3))
                .frame(width: 28, height: 2)

            Text("할 일이\n없어요")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
                .lineSpacing(2)

            Text("+ 버튼으로 오늘 해야 할 일을\n추가해보세요")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

#Preview {
    ScrollView {
        TodoListSection(
            todos: Todo.samples(),
            onEdit: { _ in },
            onToggleDone: { _ in },
            onDelete: { _ in }
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
