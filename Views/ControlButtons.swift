import SwiftUI

struct ControlButtons: View {
    @ObservedObject var timerManager: TimerManager
    @State private var showInvalidTimeAlert = false
    
    var body: some View {
        HStack(spacing: 40) {
            // Reset button
            Button(action: {
                withAnimation(.spring(dampingFraction: 0.5)) {
                    timerManager.reset()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            .disabled(timerManager.state == .idle)
            .opacity(timerManager.state == .idle ? 0.5 : 1)
            .accessibilityLabel("Reset timer")
            
            // Start/Pause button
            Button(action: {
                if timerManager.state == .running {
                    timerManager.pause()
                } else if timerManager.totalTime > 0 {
                    timerManager.start()
                }
            }) {
                ZStack {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(timerManager.state == .running ? .orange : .green)
                    
                    Image(systemName: timerManager.state == .running ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }
            .alert("Invalid Time", isPresented: $showInvalidTimeAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please set a time greater than zero")
            }
            .accessibilityLabel(timerManager.state == .running ? "Pause timer" : "Start timer")
        }
        .padding(.top, 30)
    }
}
