//
//  TodoListView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import SwiftData
import SwiftUI

struct TodoListView: View {
    @Environment(Router.self) private var router
    @Environment(TodoListViewModel.self) private var viewModel

    @State private var isAddSheetPresented = false

    private var editingTodo: Todo? {
        guard let id = router.editingTodoId else { return nil }
        return viewModel.todos.first { $0.id == id }
    }

    var body: some View {
        @Bindable var router = router

        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HeaderView(totalCount: viewModel.todos.count) {
                        isAddSheetPresented = true
                    }

                    TodoListSection(
                        todos: viewModel.todos,
                        onEdit: { router.navigate(to: .todoDetail($0.id)) },
                        onToggleDone: { todo in
                            Task { try? await viewModel.toggleDone(todo) }
                        },
                        onDelete: { todo in
                            Task { try? await viewModel.deleteTodo(todo) }
                        }
                    )
                }
                .padding(16)
                .frame(minHeight: geo.size.height)
            }
        }
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $isAddSheetPresented) {
            TodoEditorSheet { draft in
                Task {
                    try? await viewModel.addTodo(
                        title: draft.title,
                        detail: draft.detail,
                        dueDate: draft.dueDate,
                        notifies: draft.notifies
                    )
                }
                isAddSheetPresented = false
            }
        }
        .sheet(isPresented: Binding(
            get: { router.editingTodoId != nil },
            set: { if !$0 { router.editingTodoId = nil } }
        )) {
            if let todo = editingTodo {
                TodoEditorSheet(original: todo) { draft in
                    Task {
                        try? await viewModel.updateTodo(
                            todo,
                            title: draft.title,
                            detail: draft.detail,
                            dueDate: draft.dueDate,
                            notifies: draft.notifies
                        )
                    }
                    router.editingTodoId = nil
                }
            }
        }
    }
}

// MARK: - Private

private struct TodoDraft {
    let title: String
    let detail: String
    let dueDate: Date?
    let notifies: Bool
}

private struct HeaderView: View {
    let totalCount: Int
    let onAdd: () -> Void

    private let accent = Color(red: 1.0, green: 0.176, blue: 0.333)

    var body: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: 4) {
                Text("할 일")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                Text("✅")
                    .font(.system(size: 24))
            }
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(accent)
                    .clipShape(Circle())
                    .shadow(color: accent.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}

private struct TodoEditorSheet: View {
    let original: Todo?
    let onConfirm: (TodoDraft) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var detail: String
    @State private var notifies: Bool
    @State private var dueDate: Date

    private let maxTitle = 40
    private let maxDetail = 100
    private let accent = Color(red: 1.0, green: 0.176, blue: 0.333)

    private var deviceLocale: Locale {
        Locale(identifier: Locale.preferredLanguages.first ?? Locale.current.identifier)
    }

    init(original: Todo? = nil, onConfirm: @escaping (TodoDraft) -> Void) {
        self.original = original
        self.onConfirm = onConfirm
        _title = State(initialValue: original?.title ?? "")
        _detail = State(initialValue: original?.detail ?? "")
        _notifies = State(initialValue: original?.notifies ?? false)

        let fallback = Date().addingTimeInterval(60 * 60)
        let initialDue = original?.dueDate ?? fallback
        _dueDate = State(initialValue: max(initialDue, Date().addingTimeInterval(60)))
    }

    private var isEditMode: Bool {
        original != nil
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDisabled: Bool {
        trimmedTitle.isEmpty || title.count > maxTitle || detail.count > maxDetail
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            HStack {
                Text(isEditMode ? "할 일 수정 ✅" : "새 할 일 ✅")
                    .font(.system(size: 16, weight: .heavy))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: 16) {
                    field(label: "제목") {
                        VStack(spacing: 4) {
                            TextField("예: 운동 30분 하기", text: $title)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                            counter(count: title.count, limit: maxTitle)
                        }
                    }

                    field(label: "설명 (선택)") {
                        VStack(spacing: 4) {
                            TextField("메모를 남겨보세요", text: $detail, axis: .vertical)
                                .lineLimit(3 ... 3)
                                .font(.system(size: 15))
                                .padding(12)
                                .frame(minHeight: 72, alignment: .top)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                            counter(count: detail.count, limit: maxDetail)
                        }
                    }

                    Toggle(isOn: $notifies.animation()) {
                        Text("알림 받기")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .tint(accent)

                    if notifies {
                        DatePicker(
                            "알림 시각",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .font(.system(size: 15))
                        .environment(\.locale, deviceLocale)
                    }
                }
                .padding(.horizontal, 20)
            }

            HStack(spacing: 10) {
                Button("취소") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundStyle(Color(.label))
                    .font(.system(size: 15, weight: .semibold))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(isEditMode ? "수정" : "저장") {
                    onConfirm(
                        TodoDraft(
                            title: trimmedTitle,
                            detail: detail.trimmingCharacters(in: .whitespacesAndNewlines),
                            dueDate: notifies ? dueDate : nil,
                            notifies: notifies
                        )
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isDisabled ? Color(.systemGray4) : accent)
                .foregroundStyle(.white)
                .font(.system(size: 15, weight: .bold))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(isDisabled)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Color(.secondarySystemBackground))
    }

    private func counter(count: Int, limit: Int) -> some View {
        HStack {
            Spacer()
            Text("\(count) / \(limit)")
                .font(.system(size: 11))
                .foregroundStyle(count > limit ? .red : Color(.secondaryLabel))
        }
    }

    private func field(
        label: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            content()
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ActionMessageEntity.self, NotificationSettingEntity.self, TodoEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    TodoListView()
        .modelContainer(container)
        .environment(Router())
        .environment(PreviewSupport.seededTodoListViewModel(container.mainContext))
}
