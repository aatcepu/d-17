

import SwiftUI

struct ContentView: View {
    private var count = 0
    private var timer: Timer?
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Counter")
            
                .font(.largeTitle)
            
            Text("(count)")
            
                .font(.system(size: 50))
            
            HStack {
                
                Button("Start") {
                    
                    startTimer()
                    
                }
                
                Button("Stop") {
                    
                    timer?.invalidate()
                    
                }
                
                Button("Reset") {
                    
                    count = 0
                    
                }
                
            }
            
        }
        
    }
}
