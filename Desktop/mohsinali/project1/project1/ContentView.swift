import SwiftUI

// MARK: - App Entry Point
@main
struct ThemeSwitcherApp: App {
    // State object to hold the user's theme preferences globally
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Injects the theme manager into the environment
                .environmentObject(themeManager)
                // Dynamically applies Light or Dark mode globally
                .preferredColorScheme(themeManager.selectedColorScheme)
                // Dynamically applies the accent tint color globally
                .tint(themeManager.selectedAccentColor)
        }
    }
}

// MARK: - Theme Manager (State Holder)
class ThemeManager: ObservableObject {
    @Published var selectedColorScheme: ColorScheme? = nil // nil = System default
    @Published var selectedAccentColor: Color = .blue      // Default accent
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // Greeting Header
                VStack(spacing: 8) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(themeManager.selectedAccentColor)
                    
                    Text("Dynamic Theme Switcher")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Section 1: Appearance Mode (Light / Dark / System)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Appearance Mode")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button("System") {
                            themeManager.selectedColorScheme = nil
                        }
                        .buttonStyle(ThemeButtonStyle(isSelected: themeManager.selectedColorScheme == nil))
                        
                        Button("Light") {
                            themeManager.selectedColorScheme = .light
                        }
                        .buttonStyle(ThemeButtonStyle(isSelected: themeManager.selectedColorScheme == .light))
                        
                        Button("Dark") {
                            themeManager.selectedColorScheme = .dark
                        }
                        .buttonStyle(ThemeButtonStyle(isSelected: themeManager.selectedColorScheme == .dark))
                    }
                }
                
                // Section 2: Accent Color Picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Accent Color")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        ColorButton(color: .blue, name: "Blue")
                        ColorButton(color: .purple, name: "Purple")
                        ColorButton(color: .green, name: "Green")
                        ColorButton(color: .orange, name: "Orange")
                    }
                }
                
                Spacer()
                
                // Interactive elements to test the theme
                VStack(spacing: 15) {
                    Button(action: {}) {
                        Text("Sample Action Button")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.selectedAccentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                    
                    Toggle("Sample Toggle Switch", isOn: .constant(true))
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Reusable Color Button Component
struct ColorButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let color: Color
    let name: String
    
    var body: some View {
        Button(action: {
            themeManager.selectedAccentColor = color
        }) {
            VStack {
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: themeManager.selectedAccentColor == color ? 3 : 0)
                    )
                Text(name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Custom Button Style for Mode Selectors
struct ThemeButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager())
    }
}
