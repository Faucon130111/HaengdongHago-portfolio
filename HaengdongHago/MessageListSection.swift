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
                    .frame(maxHeight: .infinity)
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
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Private

private struct EmptyMessageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("0")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.15))
                .kerning(-3)

            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(width: 28, height: 2)

            Text("아직 메시지가\n없어요")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .lineSpacing(2)

            Text("+ 버튼으로 나를 행동하게\n만드는 말을 추가해보세요")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.65))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

#Preview {
    let messages = [
        ActionMessage(content: "행동하지 않으면 아무것도 일어나지 않는다.", order: 0),
        ActionMessage(content: "나는 행동한다, 고로 존재한다.", order: 1),
    ]

    ScrollView {
        MessageListSection(messages: []) { _ in }
            .padding()
    }
    .background(Color.orange.opacity(0.8))
}
