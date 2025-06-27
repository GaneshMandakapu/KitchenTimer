import SwiftUI

struct TimePicker: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 0) {
            Picker("Hours", selection: $timerManager.hours) {
                ForEach(0..<25) { hour in
                    Text("\(hour)h").tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            
            Picker("Minutes", selection: $timerManager.minutes) {
                ForEach(0..<60) { minute in
                    Text("\(minute)m").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            
            Picker("Seconds", selection: $timerManager.seconds) {
                ForEach(0..<60) { second in
                    Text("\(second)s").tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .labelsHidden()
        .frame(height: 150)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Time selection")
    }
}
