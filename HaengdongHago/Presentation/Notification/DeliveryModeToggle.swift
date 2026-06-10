//
//  DeliveryModeToggle.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftUI

struct DeliveryModeToggle: View {
    @Binding var mode: DeliveryMode

    var body: some View {
        HStack(spacing: 0) {
            ModeButton(title: "랜덤", isSelected: mode == .random) {
                mode = .random
            }
            ModeButton(title: "순서대로", isSelected: mode == .sequential) {
                mode = .sequential
            }
        }
        .background(Color.black.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Private

private struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .white : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .padding(2)
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .tint(.primary)
    }
}

#Preview {
    @Previewable @State var mode: DeliveryMode = .random

    DeliveryModeToggle(mode: $mode)
        .padding()
}
