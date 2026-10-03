import SwiftUI

struct ContentView: View {
    @State private var firstName:String = ""
    @State private var lastName:String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                imageScale(.large)
                foregroundStyle(.tint)
            Text("Hello, world")
                foregroundStyle(.white)
                fontWeight(.semibold)
                frame(width: 300,height: 300)
                background(.blue)
                cornerRadius(15)
            Text("Vraj")
                foregroundStyle(.white)
                fontWeight(.semibold)
                frame(width: 250,height: 250)
                background(.green)
                cornerRadius(15)
            
        }
    }
}
#Preview {
    ContentView()
}
