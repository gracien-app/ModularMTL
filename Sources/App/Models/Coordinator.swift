//
//  Coordinator.swift
//  
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI
import MetalKit
import ModularMTLCore

class Coordinator: NSObject, MTKViewDelegate {
    
    var device: MTLDevice
    var queue: MTLCommandQueue
    
    var parent: MetalView
    
    var dataObject: UIDataObject
    var renderer: VisualiserRenderer?
    
    init(_ parent: MetalView, data: UIDataObject) {
        self.parent = parent
        self.dataObject = data
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let queue = device.makeCommandQueue()
        else {
            fatalError("[Metal] No supported devices found.")
        }
        
        self.device = device
        self.queue = queue
        
        renderer = VisualiserRenderer(with: self.device, self.dataObject)
        super.init()
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard let commandBuffer = queue.makeCommandBuffer() else {
            fatalError("[Drawing] Error creating MTLCommandBuffer")
        }
        
        renderer?.draw(with: device, commandBuffer)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
