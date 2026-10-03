import SwiftUI

enum AvatarType: String, CaseIterable, Identifiable {
    case robot = "robot"
    case zen = "zen"
    case creative = "creative"
    case brave = "brave"
    case cool = "cool"
    case wise = "wise"
    
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .robot: return "avatar_robot"
        case .zen: return "avatar_zen"
        case .creative: return "avatar_creative"
        case .brave: return "avatar_brave"
        case .cool: return "avatar_cool"
        case .wise: return "avatar_wise"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .robot: return [.gray, .blue]
        case .zen: return [.green, .mint]
        case .creative: return [.purple, .pink]
        case .brave: return [.orange, .red]
        case .cool: return [.cyan, .blue]
        case .wise: return [.brown, .yellow]
        }
    }
}

struct AvatarView: View {
    let type: AvatarType
    var size: CGFloat = 100
    var addAnimation: Bool = false
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background Gradient Bubble
            Circle()
                .fill(
                    LinearGradient(colors: type.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: size, height: size)
                .shadow(color: type.gradientColors.last?.opacity(0.5) ?? .gray, radius: size * 0.1, x: 0, y: size * 0.05)
            
            // Inner Glare for 3D effect
            Circle()
                .fill(
                    LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .topLeading, endPoint: .center)
                )
                .frame(width: size, height: size)
                .mask(Circle().padding(size * 0.05))
            
            // 3D Avatar Image
            Image(type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.85, height: size * 0.85)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .offset(y: isAnimating ? -3 : 3)
        }
        .onAppear {
            if addAnimation {
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            AvatarView(type: .robot)
            AvatarView(type: .creative, addAnimation: true)
        }
        .padding()
        .background(Color.black)
    }
}
