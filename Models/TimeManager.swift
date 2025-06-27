import Foundation
import Combine
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

final class TimerManager: ObservableObject {
    enum TimerState: String {
        case idle
        case running
        case paused
        case completed
    }
    
    // User settings
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var progress: Double = 0.0
    @Published var state: TimerState = .idle
    @Published var roundsCompleted: Int = UserDefaults.standard.integer(forKey: "roundsCompleted")
    @Published var totalElapsedTime: TimeInterval = UserDefaults.standard.double(forKey: "totalElapsedTime")
    
    // Private properties
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var timer: AnyCancellable?
    private var notificationPlayer: AVAudioPlayer?
    
    init() {
        setupAudioPlayer()
    }
    
    // Computed properties
    var totalTime: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }
    
    var remainingTime: TimeInterval {
        max(totalTime - elapsedTime, 0)
    }
    
    var elapsedTime: TimeInterval {
        guard let startTime else { return accumulatedTime }
        return accumulatedTime + Date().timeIntervalSince(startTime)
    }
    
    var timeString: String {
        let totalSeconds = Int(remainingTime)
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        if h > 0 {
            return String(format: "%01d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
    
    var elapsedString: String {
        let totalSeconds = Int(elapsedTime)
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        if h > 0 {
            return String(format: "%01d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
    
    var formattedTotalElapsedTime: String {
        let totalSeconds = Int(totalElapsedTime)
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        if h > 0 {
            return String(format: "%01d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
    
    // Timer control
    func start() {
        guard totalTime > 0 else { return }
        
        switch state {
        case .idle, .completed:
            startTime = Date()
            accumulatedTime = 0
        case .paused:
            startTime = Date()
        default: return
        }
        
        state = .running
        startTimer()
        saveState()
    }
    
    func pause() {
        guard state == .running else { return }
        timer?.cancel()
        accumulatedTime = elapsedTime
        startTime = nil
        state = .paused
        saveState()
    }
    
    func reset() {
        timer?.cancel()
        startTime = nil
        accumulatedTime = 0
        progress = 0
        state = .idle
        clearState()
    }
    
    // Notification handling
    func playCompletionSound() {
        notificationPlayer?.play()
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    // Persistence
    private func saveState() {
        UserDefaults.standard.set(hours, forKey: "savedHours")
        UserDefaults.standard.set(minutes, forKey: "savedMinutes")
        UserDefaults.standard.set(seconds, forKey: "savedSeconds")
        UserDefaults.standard.set(accumulatedTime, forKey: "accumulatedTime")
        UserDefaults.standard.set(state.rawValue, forKey: "timerState")
        UserDefaults.standard.set(roundsCompleted, forKey: "roundsCompleted")
        UserDefaults.standard.set(totalElapsedTime, forKey: "totalElapsedTime")
    }
    
    func loadState() {
        hours = UserDefaults.standard.integer(forKey: "savedHours")
        minutes = UserDefaults.standard.integer(forKey: "savedMinutes")
        seconds = UserDefaults.standard.integer(forKey: "savedSeconds")
        accumulatedTime = UserDefaults.standard.double(forKey: "accumulatedTime")
        
        if let rawState = UserDefaults.standard.string(forKey: "timerState"),
           let savedState = TimerState(rawValue: rawState) {
            state = savedState
            if state == .running {
                state = .paused // Reset to paused state on launch
            }
        }
    }
    
    private func clearState() {
        UserDefaults.standard.removeObject(forKey: "savedHours")
        UserDefaults.standard.removeObject(forKey: "savedMinutes")
        UserDefaults.standard.removeObject(forKey: "savedSeconds")
        UserDefaults.standard.removeObject(forKey: "accumulatedTime")
        UserDefaults.standard.removeObject(forKey: "timerState")
        UserDefaults.standard.removeObject(forKey: "roundsCompleted")
        UserDefaults.standard.removeObject(forKey: "totalElapsedTime")
    }
    
    // Private methods
    private func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                
                progress = min(elapsedTime / totalTime, 1.0)
                
                if elapsedTime >= totalTime {
                    timer?.cancel()
                    state = .completed
                    playCompletionSound()
                    clearState()
                    // Update persistent stats
                    roundsCompleted += 1
                    UserDefaults.standard.set(roundsCompleted, forKey: "roundsCompleted")
                    totalElapsedTime += totalTime
                    UserDefaults.standard.set(totalElapsedTime, forKey: "totalElapsedTime")
                }
            }
    }
    
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("Alarm sound file not found")
            return
        }
        
        do {
            notificationPlayer = try AVAudioPlayer(contentsOf: soundURL)
            notificationPlayer?.prepareToPlay()
        } catch {
            print("Audio player setup failed: \(error)")
        }
    }
}
