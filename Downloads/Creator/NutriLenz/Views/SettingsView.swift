import SwiftUI

struct SettingsView: View {
    @State private var isDarkMode = false
    @State private var notificationsEnabled = true
    @State private var unitsMeasurement = "Metric (g)"
    @State private var exportDataOption = "JSON"
    
    var body: some View {
        NavigationView {
            Form {
                // App Settings Section
                Section(header: Text("App Settings")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    
                    Picker("Units", selection: $unitsMeasurement) {
                        Text("Metric (g)").tag("Metric (g)")
                        Text("Imperial (oz)").tag("Imperial (oz)")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Data Management Section
                Section(header: Text("Data Management")) {
                    NavigationLink(destination: DataExportView()) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: updateOfflineDatabase) {
                        HStack {
                            Label("Update Database", systemImage: "arrow.clockwise")
                            Spacer()
                            ActivityIndicator(isAnimating: .constant(false), style: .medium)
                        }
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.blue)
                        Text("Developer")
                        Spacer()
                        Text("NutriLenz Team")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Danger Zone Section
                Section(header: Text("Danger Zone"), footer: Text("These actions cannot be undone.")) {
                    Button("Clear All Data", role: .destructive) {
                        // Action to clear all data
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func updateOfflineDatabase() {
        // Simulate database update
        print("Updating offline database...")
    }
}

struct DataExportView: View {
    @State private var exportFormat = "JSON"
    @State private var includePhotos = true
    @State private var includeHistory = true
    
    var body: some View {
        List {
            Section(header: Text("Export Options")) {
                Picker("Format", selection: $exportFormat) {
                    Text("JSON").tag("JSON")
                    Text("CSV").tag("CSV")
                    Text("PDF").tag("PDF")
                }
                .pickerStyle(MenuPickerStyle())
                
                Toggle("Include Photos", isOn: $includePhotos)
                Toggle("Include History", isOn: $includeHistory)
            }
            
            Section {
                Button("Export Data") {
                    // Export action
                    print("Exporting data in \(exportFormat) format")
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Effective Date: January 1, 2024")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Introduction")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("NutriLenz is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.")
                
                Text("Information We Collect")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("• Camera images: Used only for food recognition and processed locally on your device.\n\n• Nutrition data: Generated based on food recognition and stored locally.\n\n• Meal history: Created and stored locally on your device.\n\n• App usage: Aggregated, anonymous data to improve our service.")
                
                Text("How We Use Your Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("• To provide food recognition services\n• To calculate nutrition information\n• To maintain your meal history\n• To improve our machine learning models (anonymized data only)")
                
                Text("Data Storage and Security")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("All data is stored locally on your device. We do not upload your images, meal history, or personal nutrition data to any servers. Our machine learning models run entirely offline on your device.")
                
                Text("Sharing of Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("We do not share, sell, or rent your personal information to third parties. Your data remains on your device at all times.")
                
                Text("Contact Us")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("If you have questions about this privacy policy, please contact us at privacy@nutriscan.example.com")
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}