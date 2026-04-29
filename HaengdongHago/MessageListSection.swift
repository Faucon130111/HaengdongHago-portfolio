//
//  MessageListSection.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftUI

struct MessageListSection: View {
    let messages: [ActionMessage]
    let onDelete: (ActionMessage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메시지 목록")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)

            if messages.isEmpty {
                EmptyMessageView()
            } else {
                VStack(spacing: 8) {
                    ForEach(messages.sorted { $0.order < $1.order }) { message in
                        MessageRowView(message: message) {
                            onDelete(message)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Private

private struct EmptyMessageView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.7))

            Text("아직 메시지가 없어요\n+ 버튼으로 추가해보세요")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    let messages = [
        ActionMessage(content: "행동하지 않으면 아무것도 일어나지 않는다.", order: 0),
        ActionMessage(content: "나는 행동한다, 고로 존재한다.", order: 1),
    ]

    ScrollView {
        MessageListSection(messages: messages) { _ in }
            .padding()
    }
    .background(Color.orange.opacity(0.8))
}
