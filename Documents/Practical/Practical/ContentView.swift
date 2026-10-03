import SwiftUI

struct ContentView: View {
    
    @State private var progress: Double = 0.0
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 25) {
            
            Text("File Download")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.blue)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("\(Int(progress * 100))%")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: startLoading) {
                Text(isLoading ? "Loading..." : "Start Loading")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isLoading)
            
            if progress >= 1.0 {
                Label("Loading Complete!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.headline)
            }
        }
        .padding()
    }
    
    func startLoading() {
        progress = 0.0
        isLoading = true
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            withAnimation(.linear(duration: 0.2)) {
                progress += 0.05
            }
            
            if progress >= 1.0 {
                progress = 1.0
                timer.invalidate()
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
