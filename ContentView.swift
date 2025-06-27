//
//  ContentView.swift
//  KitchenTimerPro
//
//  Created by GaneshBalaraju on 27/06/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var timerManager = TimerManager()
    @State private var showCompletionAlert = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.13, blue: 0.22), Color(red: 0.13, green: 0.22, blue: 0.33)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Section Title
                Text("Kitchen Timer")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.top, 40)
                
                // Timer Ring with Glow
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.2), lineWidth: 18)
                        .frame(width: 220, height: 220)
                    Circle()
                        .trim(from: 0, to: CGFloat(timerManager.progress))
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [Color.green, Color.cyan]), center: .center),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                        .shadow(color: Color.green.opacity(0.5), radius: 16, x: 0, y: 0)
                    // Timer Text
                    VStack(spacing: 6) {
                        Text(timerManager.timeString)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("100%") // Placeholder for progress percent
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.vertical, 10)
                
                // Info Cards
                HStack(spacing: 16) {
                    InfoCard(title: "ROUND", value: "\(timerManager.roundsCompleted)", subtitle: "completed", icon: "repeat")
                    InfoCard(title: "TOTAL", value: timerManager.formattedTotalElapsedTime, subtitle: "elapsed", icon: "clock")
                    InfoCard(title: "ALARM", value: timerManager.state == .completed ? "Yes" : "No", subtitle: "status", icon: "bell")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Time Picker (only when idle or completed)
                if timerManager.state == .idle || timerManager.state == .completed {
                    TimePicker(timerManager: timerManager)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Play/Pause Button
                Button(action: {
                    if timerManager.state == .running {
                        timerManager.pause()
                    } else if timerManager.totalTime > 0 {
                        timerManager.start()
                    }
                }) {
                    Image(systemName: timerManager.state == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(32)
                        .background(Circle().fill(Color.green))
                        .shadow(color: Color.green.opacity(0.5), radius: 16, x: 0, y: 0)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            timerManager.loadState()
        }
        .onChange(of: timerManager.state) { _, newState in
            if newState == .completed {
                showCompletionAlert = true
            }
        }
        .alert("Timer Complete!", isPresented: $showCompletionAlert) {
            Button("OK") {
                timerManager.reset()
            }
        } message: {
            Text("Your cooking time is finished")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kitchen Timer")
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cyan)
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ContentView()
        .previewDevice("iPhone 16 Pro")
}

