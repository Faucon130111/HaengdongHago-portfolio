//
//  NotificationSettingCard.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftData
import SwiftUI

struct NotificationSettingCard: View {
    @Environment(NotificationSettingViewModel.self) private var viewModel

    @State private var isTimePickerPresented = false

    var body: some View {
        VStack(spacing: 0) {
            // 알림 시간
            Button {
                isTimePickerPresented = true
            } label: {
                HStack {
                    Text("알림 시간")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(timeLabel)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray2))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray3))
                }
                .padding(16)
            }
            .tint(.primary)

            Divider()
                .padding(.horizontal, 16)

            // 발송 방식
            HStack {
                Text("발송 방식")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)

                Spacer()

                DeliveryModeToggle(mode: Binding(
                    get: { viewModel.deliveryMode },
                    set: { viewModel.updateDeliveryMode($0) }
                ))
            }
            .padding(16)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerSheet(
                initialHour: viewModel.hour,
                initialMinute: viewModel.minute
            ) { hour, minute in
                viewModel.updateTime(hour: hour, minute: minute)
            }
            .presentationDetents([.height(300)])
        }
    }

    // MARK: - Private

    private var timeLabel: String {
        let period = viewModel.hour < 12 ? "오전" : "오후"
        let displayHour = viewModel.hour == 0 ? 12 : (viewModel.hour > 12 ? viewModel.hour - 12 : viewModel.hour)
        let minuteStr = String(format: "%02d", viewModel.minute)
        return "매일 \(period) \(displayHour):\(minuteStr)"
    }
}

// MARK: - Private

private struct TimePickerSheet: View {
    let initialHour: Int
    let initialMinute: Int
    let onConfirm: (Int, Int) -> Void

    @State private var isPM: Bool
    @State private var displayHour: Int
    @State private var selectedMinute: Int
    @Environment(\.dismiss) private var dismiss

    init(initialHour: Int, initialMinute: Int, onConfirm: @escaping (Int, Int) -> Void) {
        self.initialHour = initialHour
        self.initialMinute = initialMinute
        self.onConfirm = onConfirm
        _isPM = State(initialValue: initialHour >= 12)
        _displayHour = State(initialValue: initialHour == 0 ? 12 : (initialHour > 12 ? initialHour - 12 : initialHour))
        _selectedMinute = State(initialValue: initialMinute)
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            HStack {
                Text("알림 시간")
                    .font(.system(size: 16, weight: .heavy))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            // ── 커스텀 휠 ──
            HStack(spacing: 0) {
                // 오전 / 오후
                Picker("", selection: $isPM) {
                    Text("오전").tag(false)
                    Text("오후").tag(true)
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                // 시 (1~12)
                Picker("", selection: $displayHour) {
                    ForEach(1 ... 12, id: \.self) { hour in
                        Text("\(hour)시").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                // 분 (00~59)
                Picker("", selection: $selectedMinute) {
                    ForEach(0 ... 59, id: \.self) { minute in
                        Text(String(format: "%02d분", minute)).tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 160)
            .padding(.horizontal, 8)

            HStack(spacing: 10) {
                Button("취소") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundStyle(Color(.label))
                    .font(.system(size: 15, weight: .semibold))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("완료") {
                    let converted: Int = switch (isPM, displayHour) {
                    case (false, 12): 0
                    case (false, _): displayHour
                    case (true, 12): 12
                    case (true, _): displayHour + 12
                    }
                    onConfirm(converted, selectedMinute)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 1.0, green: 0.176, blue: 0.333))
                .foregroundStyle(.white)
                .font(.system(size: 15, weight: .bold))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .presentationBackground(Color(.secondarySystemBackground))
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ActionMessageEntity.self, NotificationSettingEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let viewModel = PreviewSupport.notificationSettingViewModel(container.mainContext)

    NotificationSettingCard()
        .environment(viewModel)
        .padding()
        .background(Color.orange.opacity(0.3))
}
