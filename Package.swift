// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AIHub",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "AIHub",
            path: "Sources/AIHub"
        )
    ]
)
