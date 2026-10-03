import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                Text("Admin Console")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                // Input Fields
                VStack(spacing: 15) {
                    TextField("Username", text: $viewModel.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                // Login Button
                Button(action: {
                    viewModel.login()
                }) {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
            }
            .alert("Login Failed", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            // Redirects to Dashboard upon successful authentication
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                AdminDashboardView(viewModel: viewModel)
            }
        }
    }
}

// Simple placeholder for the admin dashboard
struct AdminDashboardView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to the Admin Dashboard")
                .font(.title)
                .fontWeight(.semibold)
            
            Button("Log Out") {
                viewModel.logout()
            }
            .foregroundColor(.red)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
}
