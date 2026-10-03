import SwiftUI

struct AvatarSelectionView: View {
    @Binding var selectedAvatar: AvatarType
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Choose Your Avatar")
                    .font(.title2)
                    .bold()
                    .padding(.top, 20)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(AvatarType.allCases) { avatar in
                            Button(action: {
                                HapticAgent.shared.playImpact(.medium)
                                selectedAvatar = avatar
                                dismiss()
                            }) {
                                VStack {
                                    AvatarView(type: avatar, size: 100, addAnimation: avatar == selectedAvatar)
                                        .overlay(
                                            Circle()
                                                .stroke(Theme.secondary, lineWidth: avatar == selectedAvatar ? 3 : 0)
                                                .scaleEffect(1.1)
                                        )
                                    
                                    Text(avatar.rawValue.capitalized)
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(avatar == selectedAvatar ? Theme.secondary : .gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct AvatarSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarSelectionView(selectedAvatar: .constant(.robot))
    }
}
