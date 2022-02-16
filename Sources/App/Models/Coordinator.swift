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
        handleKeyboardInput()
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard let commandBuffer = queue.makeCommandBuffer() else {
            fatalError("[Drawing] Error creating MTLCommandBuffer")
        }
        
        renderer?.draw(with: device, commandBuffer, view.currentRenderPassDescriptor!)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func handleKeyboardInput() {
        if Keyboard.IsKeyPressed(.upArrow) {
            dataObject.pointsCount += 1
        }
        else if Keyboard.IsKeyPressed(.downArrow) {
            if dataObject.pointsCount > 1 {
                dataObject.pointsCount -= 1
            }
        }
        
        if Keyboard.IsKeyPressed(.leftArrow) {
            if (dataObject.multiplier - 0.1) >= 0.0 {
                dataObject.multiplier -= 0.1
            }
            else {
                dataObject.multiplier = 0.0
            }
        }
        else if Keyboard.IsKeyPressed(.rightArrow) {
            dataObject.multiplier += 0.1
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
