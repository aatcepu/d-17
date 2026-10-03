import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraVM = CameraViewModel()
    @StateObject private var detectionVM = DetectionViewModel()
    @State private var showingResult = false
    @State private var capturedImage: UIImage?
    @State private var showPermissionAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Camera preview
                CameraPreview(cameraVM: cameraVM)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Capture button overlay
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        }
                        .onTapGesture {
                            capturePhoto()
                        }
                        .overlay(
                            ProgressView()
                                .opacity(cameraVM.isCapturing ? 1 : 0)
                        )
                        
                        Spacer()
                    }
                    
                    Text("Tap to Capture")
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
                
                // Result view when image is captured
                if showingResult {
                    NavigationLink(destination: DetectionResultView(
                        detectionResult: detectionVM.detectionResult!,
                        capturedImage: capturedImage!,
                        onSave: { meal in
                            // Save meal to history
                            // In a real implementation, we would save to Core Data
                            print("Saving meal: \(meal.name)")
                        }
                    ), isActive: $showingResult) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .alert("Camera Access Needed", isPresented: $showPermissionAlert) {
                Button("Settings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("NutriLenz needs camera access to scan food items. Please enable camera access in Settings.")
            }
        }
        .onAppear {
            cameraVM.requestCameraPermission()
        }
        .onReceive(cameraVM.$authorizationStatus) { status in
            if status == .denied || status == .restricted {
                showPermissionAlert = true
            } else if status == .authorized {
                do {
                    try cameraVM.setupCamera()
                    cameraVM.startSession()
                } catch {
                    print("Failed to setup camera: \(error)")
                }
            }
        }
    }
    
    private func capturePhoto() {
        cameraVM.capturePhoto { result in
            switch result {
            case .success(let image):
                capturedImage = image
                Task {
                    let detectionResult = await detectionVM.detectFood(in: image)
                    switch detectionResult {
                    case .success:
                        showingResult = true
                    case .failure(let error):
                        print("Detection failed: \(error)")
                    }
                }
            case .failure(let error):
                print("Capture failed: \(error)")
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraVM: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        setupCameraPreview(view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update camera preview if needed
    }
    
    private func setupCameraPreview(_ view: UIView) {
        let layer = cameraVM.getPreviewLayer()
        layer.frame = view.bounds
        if layer.superlayer == nil {
            view.layer.addSublayer(layer)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}