//
//  TodoRowView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    let onTap: () -> Void
    let onToggleDone: () -> Void
    let onDelete: () -> Void

    private let accent = Color(red: 1.0, green: 0.176, blue: 0.333)

    private var deviceLocale: Locale {
        Locale(identifier: Locale.preferredLanguages.first ?? Locale.current.identifier)
    }

    private var dueLabel: String? {
        guard let dueDate = todo.dueDate else { return nil }
        return dueDate.formatted(
            Date.FormatStyle(date: .abbreviated, time: .shortened).locale(deviceLocale)
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onToggleDone) {
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(todo.isDone ? accent : Color(.systemGray3))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(todo.isDone ? .secondary : .primary)
                    .strikethrough(todo.isDone)

                if !todo.detail.isEmpty {
                    Text(todo.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let dueLabel {
                    HStack(spacing: 4) {
                        Image(systemName: todo.notifies ? "bell.fill" : "calendar")
                            .font(.system(size: 10))
                        Text(dueLabel)
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(todo.notifies ? accent : Color(.secondaryLabel))
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.pink)
                    .padding(6)
                    .background(Color.pink.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .opacity(todo.isDone ? 0.6 : 1)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

#Preview {
    VStack(spacing: 8) {
        TodoRowView(
            todo: Todo(
                title: "운동 30분",
                detail: "스쿼트 + 러닝",
                dueDate: Date().addingTimeInterval(3600),
                notifies: true
            ),
            onTap: {}, onToggleDone: {}, onDelete: {}
        )
        TodoRowView(
            todo: Todo(title: "장보기", isDone: true),
            onTap: {}, onToggleDone: {}, onDelete: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
