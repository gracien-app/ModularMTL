# ModularMTL

### Description

Modular multiplication on a circle visualiser.  
Written in **Swift** using **Metal API** and **SwiftUI**.

### Images
![Prototype](Images/Prototype.png)


### Features
- [x] Basic UI
- [x] User keyboard controls (use *Arrow keys*),
- [x] Calculations offloaded to Compute shaders,
- [x] Managed using Swift Packages with separate local Core module containing complete rendering logic. 

### Building
- Clone the repository,
- Use `swift build -c release --arch arm64 --arch x86_64` inside your local repository clone to build universal binary in release configuration,

### Running
- Binary must be bundled together with Core module containing default metal library. 

*Universal application bundle available in releases.*
