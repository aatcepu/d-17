import SwiftUI

struct ActivitySessionView: View {
    let activity: ActivityRecommendation
    @Environment(\.dismiss) var dismiss
    @State private var isStarted = true // Started from the pre-launch sheet
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    @State private var phase = 0.0
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: { stopTimer() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.textPrimary.opacity(0.3))
                    }
                    Spacer()
                    Text("In Progress")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Visualization
                ZStack {
                    Circle()
                        .fill(activity.accentColor.opacity(0.1))
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .stroke(activity.accentColor.opacity(0.2), lineWidth: 2)
                        .frame(width: 160, height: 160)
                    
                    HealthVisualGuidance(activityName: activity.name)
                        .scaleEffect(1.3)
                }
                .padding(.vertical, 20)
                
                VStack(spacing: 12) {
                    Text(activity.name)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(activity.category.rawValue.uppercased())
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(activity.accentColor)
                }
                
                // Timer
                VStack(spacing: 16) {
                    Text(timeString)
                        .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundColor(activity.accentColor)
                        .shadow(color: activity.accentColor.opacity(0.3), radius: 10)
                    
                    Text("Focus on your breath and movement")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                // Complete Button
                Button(action: { stopTimer() }) {
                    Text("Complete Activity")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(activity.accentColor)
                        .cornerRadius(20)
                        .shadow(color: activity.accentColor.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        let durationMinutes = Int(activity.duration.components(separatedBy: " ").first ?? "5") ?? 5
        timeRemaining = durationMinutes * 60
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                t.invalidate()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        dismiss()
    }
}

// MARK: - Info Badge
struct InfoBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Theme.textPrimary.opacity(0.8))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.12), lineWidth: 0.5)
        )
    }
}

// MARK: - Health Visual Guidance
struct HealthVisualGuidance: View {
    let activityName: String
    
    @State private var phase = 0.0
    @State private var yogaPoseIndex = 0
    let yogaPoses = ["figure.yoga", "figure.flexibility", "figure.core.cylinder"]
    
    var body: some View {
        VStack {
            if activityName.contains("Yoga") {
                // Yoga Flow: Rotate poses
                Image(systemName: yogaPoses[yogaPoseIndex])
                    .font(.system(size: 60))
                    .foregroundColor(Theme.health)
                    .transition(.opacity.combined(with: .scale))
                    .id(yogaPoseIndex)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 1.0)) {
                                yogaPoseIndex = (yogaPoseIndex + 1) % yogaPoses.count
                            }
                        }
                    }
                
            } else if activityName.contains("Body Scan") {
                // Body Scan: Highlight sections gradually
                ZStack {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Image(systemName: "figure.stand")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.health)
                        .mask(
                            LinearGradient(
                                colors: [.white, .white.opacity(0)],
                                startPoint: UnitPoint(x: 0.5, y: -0.5 + phase),
                                endPoint: UnitPoint(x: 0.5, y: 0.0 + phase)
                            )
                        )
                }
                .onAppear {
                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                        phase = 1.5
                    }
                }
                
            } else if activityName.contains("Breathing") || activityName.contains("Breath") {
                // Breathing Exercise: Expanding/contracting lungs/circle
                ZStack {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.health)
                        .scaleEffect(1.0 + (phase * 0.4))
                        .opacity(0.6 + (1 - phase) * 0.4)
                    
                    Circle()
                        .stroke(Theme.health.opacity(0.5), lineWidth: 2)
                        .frame(width: 80 + (phase * 40), height: 80 + (phase * 40))
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                        phase = 1.0
                    }
                }
                
            } else if activityName.contains("Hydration") || activityName.contains("Water") || activityName.contains("Snack") || activityName.contains("Vitamin") {
                // Hydration / Nutrition: Progress bar filling
                VStack(spacing: 12) {
                    Image(systemName: activityName.contains("Water") ? "drop.fill" : "mouth.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.health)
                        .offset(y: phase * -10)
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.health.opacity(0.2))
                            .frame(width: 120, height: 10)
                        
                        Capsule()
                            .fill(Theme.health)
                            .frame(width: 120 * phase, height: 10)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                        phase = 1.0
                    }
                }
                
            } else if activityName.contains("Posture") || activityName.contains("Balance") || activityName.contains("Yoga") {
                // Posture/Balance: Leveler animation
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Theme.health.opacity(0.3), lineWidth: 2)
                        .frame(width: 150, height: 40)
                    
                    Circle()
                        .fill(Theme.health)
                        .frame(width: 20, height: 20)
                        .offset(x: phase * 60)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        phase = 1.0
                    }
                }
                
            } else if activityName.contains("HIIT") || activityName.contains("Sprint") || activityName.contains("Boxing") || activityName.contains("Jumps") {
                // Intense Fitness: Rapid pulse
                ZStack {
                    Circle()
                        .stroke(Theme.fitness.opacity(0.4), lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .scaleEffect(1.0 + phase * 0.5)
                        .opacity(1.0 - phase)
                    
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.fitness)
                        .scaleEffect(1.0 + phase * 0.2)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        phase = 1.0
                    }
                }
                
            } else if activityName.contains("Eye") || activityName.contains("Focus") || activityName.contains("Gaze") {
                // Eye Rest: Moving focus point
                ZStack {
                    Circle()
                        .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 10, height: 10)
                        .offset(x: cos(phase * 2 * .pi) * 45, y: sin(phase * 2 * .pi) * 45)
                }
                .onAppear {
                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                        phase = 1.0
                    }
                }
                
            } else if activityName.contains("Stretching") || activityName.contains("Warm") || activityName.contains("Roll") {
                // Stretching: Simple stretch pose
                Image(systemName: "figure.flexibility")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.health)
                    .rotationEffect(.degrees(phase * 15))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            phase = 1.0
                        }
                    }
            } else {
                // Fallback icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.health)
                    .scaleEffect(1.0 + (phase * 0.2))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            phase = 1.0
                        }
                    }
            }
        }
    }
}
