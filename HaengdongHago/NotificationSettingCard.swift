//
//  NotificationSettingCard.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/29/26.
//

import SwiftUI

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
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(timeLabel)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }

            Divider()
                .padding(.horizontal, 16)

            // 발송 방식
            HStack {
                Text("발송 방식")
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)

                Spacer()

                DeliveryModeToggle(mode: $setting.deliveryMode)
            }
            .padding(16)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerSheet(hour: $setting.hour, minute: $setting.minute)
                .presentationDetents([.height(300)])
        }
    }

    private var timeLabel: String {
        let period = setting.hour < 12 ? "오전" : "오후"
        let displayHour = setting.hour == 0 ? 12 : (setting.hour > 12 ? setting.hour - 12 : setting.hour)
        let minuteStr = String(format: "%02d", setting.minute)
        return "매일 \(period) \(displayHour):\(minuteStr)"
    }
}

// MARK: - Private

private struct TimePickerSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Environment(\.dismiss) private var dismiss

    /// DatePicker 연동용 바인딩
    @State private var selectedDate: Date

    init(hour: Binding<Int>, minute: Binding<Int>) {
        _hour = hour
        _minute = minute

        var components = DateComponents()
        components.hour = hour.wrappedValue
        components.minute = minute.wrappedValue
        let date = Calendar.current.date(from: components) ?? Date()
        _selectedDate = State(initialValue: date)
    }

    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: selectedDate) { _, newDate in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                    hour = components.hour ?? 7
                    minute = components.minute ?? 0
                }

            Button("완료") { dismiss() }
                .font(.system(size: 16, weight: .semibold))
                .padding(.bottom, 16)
        }
    }
}

#Preview {
    let setting = NotificationSetting()

    NotificationSettingCard(setting: setting)
        .padding()
        .background(Color.orange.opacity(0.3))
}
