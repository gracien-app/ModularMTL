// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModularMTL",
    
    platforms: [
        .macOS(.v12)
    ],
    
    products: [
      .executable(
        name: "ModularMTL",
        targets: ["ModularMTL"])
    ],
    
    dependencies: [
        .package(name: "ModularMTLCore", path: "Sources/Core")
    ],
    
    targets: [
        .executableTarget(
            name: "ModularMTL",
            dependencies: ["ModularMTLCore"],
            path: "Sources/App")
    ]
)
