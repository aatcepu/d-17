//

//  ContentView.swift

//  bscit

//

//  Created by Student on 22/07/26.

//



import SwiftUI
struct ContentView: View {
@State private var count = 0
@State private var timer: Timer?
    var body: some View {
        VStack(spacing: 20) {
            Text("Counter")
                .font(.largeTitle)
            Text("\(count)")
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
        }}
    func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    count += 1
}
}
}


#Preview {
    ContentView()
}
