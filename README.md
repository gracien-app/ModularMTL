# ModularMTL

### Description
Visualisation of modular multiplication on a circle.  
Written in **Swift** using **Metal API** and **SwiftUI**.

### Images
![Prototype](Images/Preview.png)

### Features
- [x] User keyboard controls (use *Arrow keys*),
- [x] Calculations offloaded to Compute shaders,
- [x] Managed using SPM with separate Core module for rendering logic. 

### Building
- Clone the repository,
- Use `swift build -c release --arch arm64 --arch x86_64` inside cloned folder to build universal binary in release configuration,

### Running
- Binary must be bundled together with Core bundle containing default metal library (`.metallib` file)

*Universal application bundle available in releases.*
