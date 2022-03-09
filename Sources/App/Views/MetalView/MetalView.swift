//
//  MetalView.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI
import MetalKit
import ModularMTLCore

struct MetalView: NSViewRepresentable {
    
    @EnvironmentObject var data: RendererObservableData
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, data: data)
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {}
    
    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let metalView = CustomMTKView()
        
        metalView.delegate = context.coordinator
        metalView.device = context.coordinator.device
        
        metalView.framebufferOnly = true
        metalView.enableSetNeedsDisplay = false
        metalView.preferredFramesPerSecond = data.targetFPS
        metalView.colorPixelFormat = .bgra8Unorm_srgb
        
        let W = Int(data.width/2) + 28
        let H = Int(data.height) + 28
        metalView.drawableSize = CGSize(width: W, height: H)
   
        metalView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        
        return metalView
    }
}
