//
//  MessageRowView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftUI

struct MessageRowView: View {
    let message: ActionMessage
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\"\(message.content)\"")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)

                Text(message.lastSentLabel)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
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
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    MessageRowView(
        message: ActionMessage(content: "행동하지 않으면 아무것도 일어나지 않는다.", order: 0), onDelete: {}
    )
    .padding()
    .background(Color.orange.opacity(0.2))
}
