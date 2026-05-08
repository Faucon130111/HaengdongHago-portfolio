//
//  NotificationSettingCard.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftUI

// MARK: - Notification.Name

extension Notification.Name {
    static let notificationSettingDidChange = Notification.Name(
        "com.haengdongha.notificationSettingDidChange"
    )
}

struct NotificationSettingCard: View {
    @Bindable var setting: NotificationSetting

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

                DeliveryModeToggle(mode: $setting.deliveryMode)
            }
            .padding(16)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onChange(of: setting.hour) { _, _ in postReschedule() }
        .onChange(of: setting.minute) { _, _ in postReschedule() }
        .onChange(of: setting.deliveryMode) { _, _ in postReschedule() }
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerSheet(hour: $setting.hour, minute: $setting.minute)
                .presentationDetents([.height(300)])
        }
    }

    // MARK: - Private

    private var timeLabel: String {
        let period = setting.hour < 12 ? "오전" : "오후"
        let displayHour = setting.hour == 0 ? 12 : (setting.hour > 12 ? setting.hour - 12 : setting.hour)
        let minuteStr = String(format: "%02d", setting.minute)
        return "매일 \(period) \(displayHour):\(minuteStr)"
    }

    private func postReschedule() {
        NotificationCenter.default.post(
            name: .notificationSettingDidChange,
            object: nil
        )
    }
}

// MARK: - Private

private struct TimePickerSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date
    
    // 내부 상태 (오전/오후, 시, 분 분리)
    @State private var isPM: Bool
    @State private var displayHour: Int // 1~12
    @State private var selectedMinute: Int

    init(hour: Binding<Int>, minute: Binding<Int>) {
        _hour = hour
        _minute = minute

        let hour24 = hour.wrappedValue
        _isPM = State(initialValue: hour24 >= 12)
        _displayHour = State(initialValue: hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24))
        _selectedMinute = State(initialValue: minute.wrappedValue)
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

            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
            // onChange 제거 — 완료 시에만 반영

            HStack(spacing: 10) {
                Button("취소") { dismiss() } // 그냥 닫기만 — binding 안 건드림
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundStyle(Color(.label))
                    .font(.system(size: 15, weight: .semibold))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("완료") {
                    // 여기서만 binding에 커밋
                    let components = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
                    hour = components.hour ?? 7
                    minute = components.minute ?? 0
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
        .presentationDetents([.height(300)])
        .presentationBackground(Color(.secondarySystemBackground))
    }
}

#Preview {
    let setting = NotificationSetting()

    NotificationSettingCard(setting: setting)
        .padding()
        .background(Color.orange.opacity(0.3))
}
