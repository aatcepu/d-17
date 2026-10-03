import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack{
            MapView()
                .frame(height:300)
            CircleView()
                .offset(y:-130)
                .padding(.bottom, 150)
            
        }
        VStack(alignment: .leading){
            Text("Apple Lab")
            HStack{
                Text("Parul University")
                    .font(.subheadline)
                Spacer()
                Text("Vadodara")
                    .font(.subheadline)
                
            }
        }
        .padding(.bottom,50)
        Spacer()
    }
}
#Preview {
    ContentView()
}
