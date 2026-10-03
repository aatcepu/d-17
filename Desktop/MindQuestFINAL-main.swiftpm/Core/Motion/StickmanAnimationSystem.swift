import SwiftUI

// MARK: - Stickman Shapes
struct StickmanBody: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Head
        path.addEllipse(in: CGRect(x: center.x - 10, y: center.y - 45, width: 20, height: 20))
        
        // Spine
        path.move(to: CGPoint(x: center.x, y: center.y - 25))
        path.addLine(to: CGPoint(x: center.x, y: center.y + 5))
        
        return path
    }
}

struct StickmanLimbs: Shape {
    var limbOffset: CGFloat
    var action: StickmanAction
    
    var animatableData: CGFloat {
        get { limbOffset }
        set { limbOffset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        switch action {
        case .walking:
            // Left Arm
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x - 15 - limbOffset, y: center.y + 5))
            
            // Right Arm
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x + 15 + limbOffset, y: center.y + 5))
            
            // Left Leg
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x - 15 + limbOffset, y: center.y + 35))
            
            // Right Leg
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x + 15 - limbOffset, y: center.y + 35))
            
        case .exercising:
            // Squatting arms
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x - 20, y: center.y - 10 - limbOffset))
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x + 20, y: center.y - 10 - limbOffset))
            
            // Jumping legs
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x - 10 - limbOffset, y: center.y + 25 + limbOffset))
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x + 10 + limbOffset, y: center.y + 25 + limbOffset))
            
        case .breathing:
            // Arms expanding
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addCurve(to: CGPoint(x: center.x - 25 - limbOffset, y: center.y - 10), control1: CGPoint(x: center.x - 10, y: center.y - 20), control2: CGPoint(x: center.x - 20, y: center.y - 20))
            
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addCurve(to: CGPoint(x: center.x + 25 + limbOffset, y: center.y - 10), control1: CGPoint(x: center.x + 10, y: center.y - 20), control2: CGPoint(x: center.x + 20, y: center.y - 20))
            
            // Legs static
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x - 10, y: center.y + 35))
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x + 10, y: center.y + 35))
            
        case .meditating:
            // Cross-legged
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addQuadCurve(to: CGPoint(x: center.x - 20, y: center.y + 15), control: CGPoint(x: center.x - 15, y: center.y + 5))
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addQuadCurve(to: CGPoint(x: center.x + 20, y: center.y + 15), control: CGPoint(x: center.x + 15, y: center.y + 5))
            
            // Hands on knees
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x - 15, y: center.y + 10 - limbOffset))
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x + 15, y: center.y + 10 - limbOffset))
            
        case .jumping:
            // Arms up in excitement
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x - 20, y: center.y - 35 - limbOffset))
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x + 20, y: center.y - 35 - limbOffset))
            
            // Legs spread
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x - 15 - limbOffset, y: center.y + 35))
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x + 15 + limbOffset, y: center.y + 35))
            
        case .stretching:
            // One arm reaching high, other on hip
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addQuadCurve(to: CGPoint(x: center.x - 10, y: center.y - 45 - limbOffset), control: CGPoint(x: center.x - 5, y: center.y - 30))
            
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x + 15, y: center.y - 5))
            
            // Legs steady
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x - 10, y: center.y + 35))
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x + 10, y: center.y + 35))
            
        case .thinking:
            // One hand on chin, other behind back
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x - 10 + (limbOffset/5), y: center.y - 35))
            
            path.move(to: CGPoint(x: center.x, y: center.y - 15))
            path.addLine(to: CGPoint(x: center.x + 10, y: center.y - 5))
            
            // Legs slightly apart
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x - 8, y: center.y + 35))
            path.move(to: CGPoint(x: center.x, y: center.y + 5))
            path.addLine(to: CGPoint(x: center.x + 8, y: center.y + 35))
        }
        
        return path
    }
}

// MARK: - Stickman Animation Component
enum StickmanAction {
    case walking, breathing, exercising, meditating, jumping, stretching, thinking
}

struct StickmanView: View {
    let action: StickmanAction
    let color: Color
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Body parts rendered with custom paths
            StickmanBody()
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            
            StickmanLimbs(limbOffset: phase, action: action)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            
            // Action-specific effects
            if action == .breathing {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .scaleEffect(0.5 + phase / 10)
                    .opacity(0.8 - phase / 15)
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            let duration: Double
            let range: CGFloat
            
            switch action {
            case .walking:
                duration = 0.6; range = 10
            case .breathing:
                duration = 3.0; range = 15
            case .exercising:
                duration = 0.4; range = 8
            case .meditating:
                duration = 2.0; range = 3
            case .jumping:
                duration = 0.5; range = 12
            case .stretching:
                duration = 1.5; range = 10
            case .thinking:
                duration = 2.5; range = 5
            }
            
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                phase = range
            }
        }
    }
    
    static func action(for category: ActivityCategory) -> StickmanAction {
        switch category {
        case .health: return .meditating
        case .fitness: return .stretching
        case .music: return .breathing
        case .games: return .jumping
        case .puzzles: return .thinking
        }
    }
}

struct StickmanAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            VStack(spacing: 50) {
                StickmanView(action: .walking, color: Theme.secondary)
                StickmanView(action: .exercising, color: Theme.health)
                StickmanView(action: .breathing, color: Theme.primary)
                StickmanView(action: .meditating, color: Theme.wellness)
            }
        }
    }
}
