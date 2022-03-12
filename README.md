<img align="left" width="95" height="95" src="Images/AppIcon.png">

# ModularMTL

## About
Visualisation of modular multiplication on a circle.  
Written in **Swift** using **Metal API** and **SwiftUI**.

## Images
![Prototype](Images/Preview.png)

## Features
- [x] Keyboard controls (Arrow keys),
- [x] Calculations offloaded to Compute shaders,
- [x] Managed using SPM with separate Core module. 

## Building
Binary must be bundled together with Core bundle containing default Metal library (`.metallib` file).  
The easiest way to do that, is using [swift-bundler](https://github.com/stackotter/swift-bundler) tool.  

Once set up, it can create application bundle with proper structure and Metal library included in Core bundle.

```sh
git clone https://github.com/JezewskiG/ModularMTL
cd ModularMTL

# Build Universal binary in Release configuration. Application bundle will be created in your current directory.
swift bundler build -c release -o .
```

*Universal application bundle available in releases.*
