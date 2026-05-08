//
//  MessageListView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftData
import SwiftUI

struct MessageListView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \ActionMessage.order) private var messages: [ActionMessage]
    @Query private var settings: [NotificationSetting]

    @State private var isAddSheetPresented = false
    @State private var editingMessage: ActionMessage?

    private var setting: NotificationSetting {
        if let existing = settings.first {
            return existing
        }

        let newSetting = NotificationSetting()
        context.insert(newSetting)
        return newSetting
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 헤더
                    HeaderView(totalCount: messages.count) {
                        isAddSheetPresented = true
                    }

                    // 알림 설정 카드
                    NotificationSettingCard(setting: setting)

                    // 메시지 목록
                    MessageListSection(
                        messages: messages,
                        onEdit: { editingMessage = $0 },
                        onDelete: { context.delete($0) }
                    )
                }
                .padding(16)
                .frame(minHeight: geo.size.height)
            }
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(red: 1.0, green: 0.176, blue: 0.333), location: 0.00), // #ff2d55 핫핑크
                    .init(color: Color(red: 1.0, green: 0.369, blue: 0.227), location: 0.35), // #ff5e3a 코랄
                    .init(color: Color(red: 1.0, green: 0.584, blue: 0.000), location: 0.75), // #ff9500 오렌지
                    .init(color: Color(red: 1.0, green: 0.800, blue: 0.000), location: 1.00), // #ffcc00 옐로우
                ],
                startPoint: UnitPoint(x: 0.3, y: 0.0),
                endPoint: UnitPoint(x: 0.7, y: 1.0)
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $isAddSheetPresented) {
            MessageEditorSheet(title: "새 행동 메시지 🔥", buttonLabel: "저장") { content in
                context.insert(ActionMessage(content: content, order: (messages.last?.order ?? -1) + 1))
                isAddSheetPresented = false
            }
        }
        .sheet(item: $editingMessage) { message in
            MessageEditorSheet(
                title: "행동 메시지 수정 🔥",
                buttonLabel: "수정",
                initialText: message.content,
                originalContent: message.content
            ) { newContent in
                message.content = newContent
                editingMessage = nil
            }
        }
    }
}

// MARK: - Private

private struct HeaderView: View {
    let totalCount: Int
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: 4) {
                Text("행동 메시지")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                Text("🔥")
                    .font(.system(size: 28))
                    .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 0)
            }
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.176, blue: 0.333))
                    .frame(width: 34, height: 34)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
    }
}

private struct MessageEditorSheet: View {
    let title: String
    let buttonLabel: String
    let originalContent: String?
    let onConfirm: (String) -> Void

    @State private var text: String
    @Environment(\.dismiss) private var dismiss

    private let maxChar = 100

    init(
        title: String,
        buttonLabel: String,
        initialText: String = "",
        originalContent: String? = nil,
        onConfirm: @escaping (String) -> Void
    ) {
        self.title = title
        self.buttonLabel = buttonLabel
        self.originalContent = originalContent
        self.onConfirm = onConfirm
        _text = State(initialValue: initialText)
    }

    private var isDisabled: Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let isUnchanged = originalContent.map { trimmed == $0 } ?? false
        return isUnchanged || trimmed.isEmpty || text.count > maxChar
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .heavy))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            TextField("예: 완벽한 타이밍은 없다. 지금이 가장 빠른 타이밍이다.", text: $text, axis: .vertical)
                .lineLimit(5 ... 5)
                .font(.system(size: 15))
                .frame(minHeight: 100)
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                .padding(.horizontal, 20)

            HStack {
                Spacer()
                Text("\(text.count) / \(maxChar)")
                    .font(.system(size: 11))
                    .foregroundStyle(text.count > maxChar ? .red : Color(.secondaryLabel))
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 16)

            HStack(spacing: 10) {
                Button("취소") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundStyle(Color(.label))
                    .font(.system(size: 15, weight: .semibold))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(buttonLabel) { onConfirm(text.trimmingCharacters(in: .whitespaces)) }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isDisabled ? Color(.systemGray4) : Color(red: 1.0, green: 0.176, blue: 0.333))
                    .foregroundStyle(.white)
                    .font(.system(size: 15, weight: .bold))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(isDisabled)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .presentationDetents([.height(280)])
        .presentationBackground(Color(.secondarySystemBackground))
    }
}

#Preview {
    MessageListView()
        .modelContainer(
            for: [ActionMessage.self, NotificationSetting.self],
            inMemory: true
        )
}
