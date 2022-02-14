// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModularMTLCore",
    
    platforms: [
        .macOS(.v11)
    ],
   
    products: [
        .library(
            name: "ModularMTLCore",
            targets: ["ModularMTLCore"]),
    ],
    
    targets: [
        .target(
          name: "ModularMTLCore",
          path: "Sources",
          resources: [
            .process("Shaders/")
          ])
    ]
)
