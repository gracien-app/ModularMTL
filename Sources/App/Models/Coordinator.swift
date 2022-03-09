import SwiftUI
import MetalKit
import ModularMTLCore

class Coordinator: NSObject, MTKViewDelegate {

    // MARK: - Parameters
    var parent: MetalView
    var renderer: ModularRenderer!
    
    
    // MARK: - Metal Parameters
    var device: MTLDevice!
    var queue: MTLCommandQueue?
    var renderTexturePSO: MTLRenderPipelineState?
    
    
    // MARK: - Methods
    init(_ parent: MetalView, data: RendererObservableData) {
        self.parent = parent
    
        if let device = MTLCreateSystemDefaultDevice(),
           let renderer = ModularRenderer(with: device, data) {
            self.device = device
            self.renderer = renderer
            
            guard let queue = device.makeCommandQueue() else {
                fatalError("[Coordinator] Error creating Metal command queue.")
            }
            self.queue = queue
            
            guard let vertexFunction = renderer.library.addFunction(name: "quadVertexFunction"),
                  let fragmentFunction = renderer.library.addFunction(name: "quadFragmentFunction") else {
                fatalError("[Coordinator] Error creating Quad vertex & fragment functions.")
            }
        
            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
            renderPipelineDescriptor.vertexFunction = vertexFunction
            renderPipelineDescriptor.fragmentFunction = fragmentFunction
            renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
            
            do {
                self.renderTexturePSO = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        else {
            data.status = .MetalUnsupported
        }
        
        super.init()
    }
    
    func draw(in view: MTKView) {
        
        if parent.data.status != .MetalUnsupported {
            handleKeyboardInput()
            
            guard let commandBuffer = queue?.makeCommandBuffer() else {
                fatalError("[Drawing] Error creating MTLCommandBuffer")
            }
            
            commandBuffer.addCompletedHandler { cmndBuffer in
                let start = cmndBuffer.gpuStartTime
                let end = cmndBuffer.gpuEndTime
                let sFrametime = end - start
                let msFrametime = sFrametime * 1000
                
                DispatchQueue.main.async {
                    self.renderer?.data.averageFrametime(new: msFrametime)
                }
            }
            
            renderer?.draw(with: device!, commandBuffer)
            
            guard let drawable = view.currentDrawable else {
                return
            }
            
            let renderDesc = view.currentRenderPassDescriptor!
            
            encodeQuadRender(to: commandBuffer, with: renderDesc)
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    private func encodeQuadRender(to commandBuffer: MTLCommandBuffer,
                                  with descriptor: MTLRenderPassDescriptor) {
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        
        renderEncoder.setRenderPipelineState(self.renderTexturePSO!)
        renderEncoder.setFragmentTexture(renderer?.getDrawable(), index: 0)
        renderEncoder.setFragmentTexture(renderer?.getBlurTexture(), index: 1)
        renderEncoder.setFragmentBytes(&renderer!.data.blur, length: MemoryLayout<uint8>.stride, index: 0)
        renderEncoder.setFragmentBytes(&renderer!.data.multiplier, length: MemoryLayout<simd_float1>.stride, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
    }
    
    private func handleKeyboardInput() {
        if Keyboard.IsKeyPressed(.upArrow) {
            renderer?.adjustPointCount(by: 1)
        }
        else if Keyboard.IsKeyPressed(.downArrow) {
            renderer?.adjustPointCount(by: -1)
        }
        if Keyboard.IsKeyPressed(.leftArrow) {
            renderer?.adjustMultiplier(by: -0.1)
        }
        else if Keyboard.IsKeyPressed(.rightArrow) {
            renderer?.adjustMultiplier(by: 0.1)
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
