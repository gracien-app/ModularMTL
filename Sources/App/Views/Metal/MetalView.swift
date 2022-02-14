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
    
    @EnvironmentObject var data: UIDataObject
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, data: data)
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {}
    
    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let metalView = MTKView()
        
        metalView.delegate = context.coordinator
        metalView.device = context.coordinator.device
        
        metalView.framebufferOnly = true
        metalView.enableSetNeedsDisplay = false
        metalView.preferredFramesPerSecond = data.targetFPS
        
        let W = Int(data.width / 2.0)
        let H = Int(data.height)
        metalView.setFrameSize(NSSize(width: W, height: H))
        metalView.drawableSize = CGSize(width: W, height: H)
        metalView.clearColor = MTLClearColorMake(0.117, 0.117, 0.117, 1.0)
        
        return metalView
    }
}
