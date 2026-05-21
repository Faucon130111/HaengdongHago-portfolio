//
//  MessageListView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftData
import SwiftUI

struct MessageListView: View {
    @Environment(Router.self) private var router
    @Environment(MessageListViewModel.self) private var viewModel

    @State private var isAddSheetPresented = false

    private var editingMessage: ActionMessage? {
        guard let id = router.editingMessageId else { return nil }
        return viewModel.messages.first { $0.id == id }
    }

    var body: some View {
        @Bindable var router = router

        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 헤더
                    HeaderView(totalCount: viewModel.messages.count) {
                        isAddSheetPresented = true
                    }

                    // 알림 설정 카드
                    NotificationSettingCard()

                    // 메시지 목록
                    MessageListSection(
                        messages: viewModel.messages,
                        onEdit: { router.navigate(to: .messageDetail($0.id)) },
                        onDelete: { message in
                            Task { try? await viewModel.deleteMessage(message) }
                        }
                    )
                }
                .padding(16)
                .frame(minHeight: geo.size.height)
            }
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(red: 1.0, green: 0.176, blue: 0.333), location: 0.00),
                    .init(color: Color(red: 1.0, green: 0.369, blue: 0.227), location: 0.35),
                    .init(color: Color(red: 1.0, green: 0.584, blue: 0.000), location: 0.75),
                    .init(color: Color(red: 1.0, green: 0.800, blue: 0.000), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.3, y: 0.0),
                endPoint: UnitPoint(x: 0.7, y: 1.0)
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $isAddSheetPresented) {
            MessageEditorSheet { content in
                Task { try? await viewModel.addMessage(content: content) }
                isAddSheetPresented = false
            }
        }
        .sheet(isPresented: Binding(
            get: { router.editingMessageId != nil },
            set: { if !$0 { router.editingMessageId = nil } }
        )) {
            if let message = editingMessage {
                MessageEditorSheet(originalContent: message.content) { newContent in
                    Task { try? await viewModel.updateMessage(message, content: newContent) }
                    router.editingMessageId = nil
                }
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
    let originalContent: String?
    let onConfirm: (String) -> Void

    @State private var text: String
    @Environment(\.dismiss) private var dismiss

    private let maxChar = 100

    init(originalContent: String? = nil, onConfirm: @escaping (String) -> Void) {
        self.originalContent = originalContent
        self.onConfirm = onConfirm
        _text = State(initialValue: originalContent ?? "")
    }

    private var isEditMode: Bool {
        originalContent != nil
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
                Text(isEditMode ? "행동 메시지 수정 🔥" : "새 행동 메시지 🔥")
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

                Button(isEditMode ? "수정" : "저장") {
                    onConfirm(text.trimmingCharacters(in: .whitespaces))
                }
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
    let container = try! ModelContainer(
        for: ActionMessageEntity.self, NotificationSettingEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let viewModel = PreviewSupport.messageListViewModel(container.mainContext)
    let settingViewModel = PreviewSupport.notificationSettingViewModel(container.mainContext)

    MessageListView()
        .modelContainer(container)
        .environment(Router())
        .environment(viewModel)
        .environment(settingViewModel)
}
