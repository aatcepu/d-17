import XCTest
@testable import LabLinkCore

final class LabLinkTests: XCTestCase {

    // MARK: - Network Monitor

    func testLinkLocalAddressDetection() {
        // Verify it doesn't crash — will return false without hardware
        let hasLinkLocal = NetworkMonitor.hasLinkLocalAddress()
        XCTAssertNotNil(hasLinkLocal)
    }

    // MARK: - Handshake PIN Generation

    func testPinGeneration() {
        let expectation = XCTestExpectation(description: "State change")

        let manager = HandshakeManager(
            onStateChange: { _ in
                expectation.fulfill()
            },
            onPermissionRequest: { _, callback in callback(true) },
            onSessionEstablished: { _ in }
        )

        let pin = manager.generatePin()

        // PIN must be exactly 6 digits
        XCTAssertEqual(pin.count, 6)
        XCTAssertNotNil(Int(pin), "PIN must be numeric")
        XCTAssertTrue((0...999999).contains(Int(pin)!), "PIN must be 0–999999")

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Discovery Service Constants

    func testDiscoveryServiceConstants() {
        XCTAssertEqual(DiscoveryService.serviceType, "_lablink._udp")
        XCTAssertEqual(DiscoveryService.serviceDomain, "local")
        XCTAssertEqual(DiscoveryService.teacherName, "LabLink-Teacher")
    }

    // MARK: - TCC Preflight

    func testTCCPreflightDoesNotCrash() {
        if #available(macOS 14.0, *) {
            let _ = CaptureSession.preflightScreenCaptureAccess()
        }
    }

    // MARK: - Chip Detector

    func testChipDetectorDoesNotCrash() {
        let chip = ChipDetector.detect()
        // Just verify it returns something
        switch chip {
        case .m1, .m2, .m3, .m4, .m5, .unknown:
            break // All valid
        }
    }

    func testRecommendedCodecReturnsValid() {
        let codec = ChipDetector.recommendedCodec
        switch codec {
        case .hevc444, .prores422proxy, .prores4444xq:
            break // All valid
        }
    }
}
