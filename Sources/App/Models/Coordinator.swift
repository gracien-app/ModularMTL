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

    // MARK: - Parameters
    var parent: MetalView
    var renderer: ModularRenderer!
    
    
    // MARK: - Metal Parameters
    var device: MTLDevice?
    var queue: MTLCommandQueue?
    
    
    // MARK: - Methods
    init(_ parent: MetalView, data: RendererObservableData) {
        self.parent = parent
        super.init()
        
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
            do {
                let renderer = try ModularRenderer(with: data, device: device)
                self.renderer = renderer
                
                guard let queue = device.makeCommandQueue() else {
                    data.error = RendererError.FatalError(Details: "Error creating MTLCommandQueue.")
                    return
                }
                self.queue = queue
            }
            catch {
                data.error = error
            }
        }
        else {
            data.error = RendererError.UnsupportedDevice(Details: "No supported Metal devices found.")
        }
    }
    
    
    func draw(in view: MTKView) {
        
        if parent.data.status != .FatalError {
            
            handleKeyboardInput()
            
            guard let commandBuffer = queue?.makeCommandBuffer() else {
                parent.data.error = RendererError.FatalError(Details: "Error creating MTLCommandBuffer.")
                return
            }
            
            commandBuffer.addCompletedHandler { cmndBuffer in
                let startTime = cmndBuffer.gpuStartTime
                let endTime = cmndBuffer.gpuEndTime
                let secTime = endTime - startTime
                let msTime = secTime * 1000
                
                DispatchQueue.main.async {
                    self.parent.data.averageFrametime(new: msTime)
                }
            }
            
            renderer.encodeDraw(to: commandBuffer)
            
            guard let drawable = view.currentDrawable,
                  let viewRPD = view.currentRenderPassDescriptor
            else { return }
            
            renderer.encodeDrawToView(to: commandBuffer, with: viewRPD)
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    
    private func handleKeyboardInput() {
        if Keyboard.IsKeyPressed(.upArrow) {
            renderer.adjustPointCount(by: 1)
        }
        else if Keyboard.IsKeyPressed(.downArrow) {
            renderer.adjustPointCount(by: -1)
        }
        if Keyboard.IsKeyPressed(.leftArrow) {
            renderer.adjustMultiplier(by: -0.1)
        }
        else if Keyboard.IsKeyPressed(.rightArrow) {
            renderer.adjustMultiplier(by: 0.1)
        }
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
