// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModularMTL",
    
    platforms: [
        .macOS(.v13)
    ],
    
    products: [
        .executable( name: "ModularMTL", targets: ["ModularMTL"])
    ],
    
    targets: [
        .target(name: "ModularMTLCore",
                path: "Sources/Core",
                resources: [.process("Shaders")]),
        
        .executableTarget(name: "ModularMTL",
                          dependencies: ["ModularMTLCore"],
                          path: "Sources/App")
    ]
)
