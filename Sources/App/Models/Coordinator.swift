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
    
    let quadVertexBuffer: MTLBuffer
    let quadRenderPSO: MTLRenderPipelineState
    
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
        
        let quadVertexData: [simd_float4] = [
            .init(x: -1.0, y: 1.0, z: 0.0, w: 0.0),
            .init(x: -1.0, y: -1.0, z: 0.0, w: 1.0),
            .init(x: 1.0, y: -1.0, z: 1.0, w: 1.0),
            .init(x: -1.0, y: 1.0, z: 0.0, w: 0.0),
            .init(x: 1.0, y: -1.0, z: 1.0, w: 1.0),
            .init(x: 1.0, y: 1.0, z: 1.0, w: 0.0),
        ]
        
        self.quadVertexBuffer = device.makeBuffer(bytes: quadVertexData,
                                              length: MemoryLayout<simd_float4>.stride * quadVertexData.count)!
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = renderer?.getFunction("quadVertexFunction")
        renderPipelineDescriptor.fragmentFunction = renderer?.getFunction("quadFragmentFunction")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        renderPipelineDescriptor.sampleCount = data.sampleCount
        
        self.quadRenderPSO = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        
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
        
        commandBuffer.addCompletedHandler { cmdBuffer in
            let start = cmdBuffer.gpuStartTime
            let end = cmdBuffer.gpuEndTime
            let sFrametime = end - start
            let msFrametime = sFrametime * 1000
            
            DispatchQueue.main.async {
                self.dataObject.frametime = msFrametime
            }
        }
        
        renderer?.draw(with: device, commandBuffer)
        
        let renderDesc = view.currentRenderPassDescriptor!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDesc)!
        
        renderEncoder.setRenderPipelineState(self.quadRenderPSO)
        renderEncoder.setVertexBuffer(self.quadVertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(renderer?.getDrawable(), index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func handleKeyboardInput() {
        if Keyboard.IsKeyPressed(.upArrow) {
            dataObject.pointsCount += 1
        }
        else if Keyboard.IsKeyPressed(.downArrow) {
            if dataObject.pointsCount > 2 {
                dataObject.pointsCount -= 1
            }
        }
        
        if Keyboard.IsKeyPressed(.leftArrow) {
            dataObject.multiplier -= 0.1
        }
        else if Keyboard.IsKeyPressed(.rightArrow) {
            dataObject.multiplier += 0.1
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
