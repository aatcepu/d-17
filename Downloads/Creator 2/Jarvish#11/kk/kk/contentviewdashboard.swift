import SwiftUI

struct contentviewdashboard: View {
    @State private var GotoLogin:Bool = false
    @State private var GotoSignup:Bool = false
    var body: some View {
        NavigationStack{
            ScrollView{
                
                VStack{
                    Image(.music)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 440, height: 500)
                    
                    Text("Your daily soundtrack, just a tap away. Welcome back!")
                        .padding(10)
                        .font(.system(size: 20))
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button{
                        GotoLogin = true
                    }label: {
                        Text("Login")
                            .padding()
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 215, height: 50)
                            .background(.blue)
                            .cornerRadius(15)
                    }
                    Button{
                        GotoSignup = true
                    }label: {
                        Text("Sign Up")
                            .padding()
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 215, height: 50)
                            .background(.green)
                            .cornerRadius(15)
                    }
                    
                    
                    
                    .navigationDestination(isPresented: $GotoLogin)
                    {
                        login()
                        
                    }
                    
                        .navigationDestination(isPresented: $GotoSignup)
                        {
                            signup()
                        }
                        
                    }
                }
            }
        }
    }

#Preview {
    ContentView()
}
