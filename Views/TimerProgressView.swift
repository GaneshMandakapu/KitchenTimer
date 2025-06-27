import SwiftUI

struct TimerProgressView: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundStyle(.gray)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundStyle(colorScheme == .dark ? .blue : .orange)
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.5), value: timerManager.progress)
            
            // Timer text
            VStack {
                Text(timeString(time: timerManager.remainingTime))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.spring(), value: timerManager.remainingTime)
                
                if timerManager.state == .completed {
                    Text("Timer Complete!")
                        .font(.title2)
                        .foregroundStyle(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: 300, height: 300)
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Timer progress: \(Int(timerManager.progress * 100)) percent")
    }
    
    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
