import SwiftUI

struct ActivityPreStartSheet: View {
    let activity: ActivityRecommendation
    var onStart: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var animateContent = false
    @State private var animateImage = false
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            // Decorative background elements
            Circle()
                .fill(activity.accentColor.opacity(0.1))
                .frame(width: 400, height: 400)
                .offset(x: 150, y: -200)
                .blur(radius: 60)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.textPrimary.opacity(0.3))
                    }
                    
                    Spacer()
                    
                    Text(activity.category.rawValue.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .kerning(1.2)
                        .foregroundColor(activity.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(activity.accentColor.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Invisible placeholder for centering
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Hero Image Section
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    LinearGradient(
                                        colors: [activity.accentColor.opacity(0.2), activity.accentColor.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 240)
                            
                            if activity.category == .health || activity.category == .fitness {
                                StickmanView(action: StickmanView.action(for: activity.category), color: activity.accentColor)
                                    .scaleEffect(1.8)
                                    .shadow(color: activity.accentColor.opacity(0.3), radius: 10)
                                    .offset(y: animateImage ? -10 : 0)
                            } else {
                                Image(systemName: activity.heroImage)
                                    .font(.system(size: 100))
                                    .foregroundColor(activity.accentColor)
                                    .shadow(color: activity.accentColor.opacity(0.4), radius: 15)
                                    .scaleEffect(animateImage ? 1.1 : 1.0)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        VStack(spacing: 12) {
                            Text(activity.name)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 20) {
                                Label(activity.duration, systemImage: "clock.fill")
                                Label(activity.difficulty, systemImage: "bolt.fill")
                            }
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Theme.textSecondary)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        Divider()
                            .background(Theme.divider)
                            .padding(.horizontal, 40)
                        
                        // Instructions Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text(activity.instructions)
                                .font(.system(.body, design: .rounded))
                                .lineSpacing(6)
                                .foregroundColor(Theme.textPrimary.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Fixed Bottom Button
                VStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onStart()
                        }
                    }) {
                        Text("Start Activity")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [activity.accentColor, activity.accentColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: activity.accentColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .background(
                    Theme.navyGradient.opacity(0.8)
                        .blur(radius: 20)
                        .ignoresSafeArea()
                )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateImage = true
            }
        }
    }
}

private struct Label: View {
    let text: String
    let systemImage: String
    
    init(_ text: String, systemImage: String) {
        self.text = text
        self.systemImage = systemImage
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)
            Text(text)
        }
    }
}
