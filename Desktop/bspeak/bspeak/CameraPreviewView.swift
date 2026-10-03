//
//  CameraPreviewView.swift
//  bspeak
//
//  Created by Student on 31/08/26.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraUIView {
        let view = CameraUIView()
        view.setupPreview(with: session)
        return view
    }

    func updateUIView(_ uiView: CameraUIView, context: Context) {}
}

class CameraUIView: UIView {

    private var previewLayer: AVCaptureVideoPreviewLayer?

    func setupPreview(with session: AVCaptureSession) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        previewLayer = layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

#Preview {
    ZStack {
        Color.bsBackground.ignoresSafeArea()
        VStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .font(.system(size: 36))
                .foregroundColor(.bsPrimary)
            Text("Camera preview")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.bsTextPrimary)
            Text("Requires real device")
                .font(.system(size: 12))
                .foregroundColor(.bsTextMuted)
        }
    }
    .preferredColorScheme(.light)
}
