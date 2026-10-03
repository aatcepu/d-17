import SwiftUI
struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""
    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
            TextField("Enter Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            SecureField("Enter Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            Button(action: validateLogin) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Text(message)
                .foregroundColor(.red)
        }
        .padding()
    }
    func validateLogin() {
        if username == "Admin" && password == "1234" {
            message = "Login Successful ✅"
        } else {
            message = "Invalid Credentials ❌"
        }
    }
}
#Preview {
    ContentView()
}
