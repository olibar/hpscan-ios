// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HPScanKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HPScanKit", targets: ["HPScanKit"]),
        .executable(name: "hpscankit-cli", targets: ["hpscankit-cli"]),
    ],
    targets: [
        .target(name: "HPScanKit", swiftSettings: [.swiftLanguageMode(.v6)]),
        .executableTarget(
            name: "hpscankit-cli",
            dependencies: ["HPScanKit"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "HPScanKitTests",
            dependencies: ["HPScanKit"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
