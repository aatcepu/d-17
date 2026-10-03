// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LabLink",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "LabLinkD", targets: ["LabLinkD"]),
        .library(name: "LabLinkCore", targets: ["LabLinkCore"]),
    ],
    targets: [
        // C header for cross-platform handshake protocol
        .target(
            name: "CHandshake",
            path: "Sources/CHandshake",
            publicHeadersPath: "include"
        ),
        // Core library with all business logic
        .target(
            name: "LabLinkCore",
            dependencies: ["CHandshake"],
            path: "Sources/LabLinkCore",
            linkerSettings: [
                .linkedFramework("Network"),
                .linkedFramework("ScreenCaptureKit"),
                .linkedFramework("VideoToolbox"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("IOSurface"),
                .linkedFramework("Security"),
                .linkedFramework("AppKit"),
            ]
        ),
        // Daemon executable
        .executableTarget(
            name: "LabLinkD",
            dependencies: ["LabLinkCore"],
            path: "Sources/LabLinkD"
        ),
        // Tests
        .testTarget(
            name: "LabLinkTests",
            dependencies: ["LabLinkCore"]
        ),
    ]
)
