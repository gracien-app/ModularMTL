//
//  VisualiserRenderer.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import Foundation
import MetalKit
import MetalPerformanceShaders

public class VisualiserRenderer: Renderer {
    
    var device: MTLDevice
    var data: UIDataObject
    var library: Library
    
    var pointsBuffer: ManagedBuffer<simd_float2>
    var linesBuffer: ManagedBuffer<simd_float4>
    
    var offscreenRenderTexture: MTLTexture
    
    var blurTexture: MTLTexture
    var blurKernel: MPSUnaryImageKernel
    
    
    let offscreenRenderPD: MTLRenderPassDescriptor
    let offscreenRenderPSO: MTLRenderPipelineState
    
    let computeLinesPSO: MTLComputePipelineState
    let computePointsPSO: MTLComputePipelineState
    
    private var M: Float!
    private var linesValid: Bool = true
    var currentMultiplier: Float {
        get {
            return M
        }
        set {
            if newValue != M {
                linesValid = false
            }
            else {
                linesValid = true
            }
            M = newValue
        }
    }
    
    public func getDrawable() -> MTLTexture {
        return self.offscreenRenderTexture
    }
    
    public func getBlurTexture() -> MTLTexture {
        return self.blurTexture
    }
    
    public func getFunction(_ name: String) -> MTLFunction? {
        if let function = library.getFunction(name: name) {
            return function
        }
        return nil
    }
    
    public init(with device: MTLDevice, _ data: UIDataObject) {
        self.device = device
        self.data = data
        self.library = Library(with: device,
                               functions: ["computePointsFunction", "computeLinesFunction",
                                           "fragmentFunction", "quadFragmentFunction",
                                           "linesVertexFunction", "quadVertexFunction"])
        
        let minimumSize: UInt = 200
        self.pointsBuffer = ManagedBuffer(with: device, count: data.pointsCount, minimum: minimumSize, label: "PointsBuffer")
        self.linesBuffer = ManagedBuffer(with: device, count: data.pointsCount, minimum: minimumSize, label: "LinesBuffer")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.getFunction(name: "linesVertexFunction")
        renderPipelineDescriptor.fragmentFunction = library.getFunction(name: "fragmentFunction")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        renderPipelineDescriptor.sampleCount = data.sampleCount
        
        do {
            computePointsPSO = try device.makeComputePipelineState(function: library.getFunction(name: "computePointsFunction")!)
            computeLinesPSO = try device.makeComputePipelineState(function: library.getFunction(name: "computeLinesFunction")!)
            offscreenRenderPSO = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            fatalError("[Metal] Error creating PSO.")
        }
        
        self.offscreenRenderTexture = TextureManager.getTexture(with: device,
                                                                      format: .bgra8Unorm_srgb,
                                                                      sizeWH: (Int(data.width / 2.0 + 28) * 2,
                                                                               Int(data.height + 28) * 2),
                                                                      type: .renderTarget)!
        
        self.blurTexture = TextureManager.getTexture(with: device,
                                                     format: .bgra8Unorm_srgb,
                                                     sizeWH: (Int(data.width / 2.0 + 28) * 2,
                                                              Int(data.height + 28) * 2),
                                                     type: .readWrite)!
        
        self.offscreenRenderPD = MTLRenderPassDescriptor()
        self.offscreenRenderPD.colorAttachments[0].texture = self.offscreenRenderTexture
        self.offscreenRenderPD.colorAttachments[0].loadAction = .clear
        self.offscreenRenderPD.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.offscreenRenderPD.colorAttachments[0].storeAction = .store
        
        self.blurKernel = MPSImageGaussianBlur(device: device, sigma: 55)
        
        self.currentMultiplier = data.multiplier
    }

    public func draw(with device: MTLDevice, _ commandBuffer: MTLCommandBuffer) {
        let pointsCount = simd_uint1(data.pointsCount)
        self.currentMultiplier = data.multiplier
        
        pointsBuffer.updateStatus(points: UInt(pointsCount))
        linesBuffer.updateStatus(points: UInt(pointsCount))
        
        if pointsBuffer.isValid == false {
            encodePointsPass(target: pointsBuffer.contents(),
                             commandBuffer: commandBuffer,
                             elementCount: pointsCount)
            self.linesValid = false
        }
        
        if self.linesValid == false {
            encodeLinesPass(from: pointsBuffer.contents(),
                                  to: linesBuffer.contents(),
                                  commandBuffer: commandBuffer,
                                  elementCount: pointsCount,
                                  multiplier: self.currentMultiplier)
            
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: self.offscreenRenderPD)!
            renderEncoder.setRenderPipelineState(offscreenRenderPSO)
            renderEncoder.setVertexBuffer(linesBuffer.contents(), offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: Int(pointsCount*2))
            renderEncoder.endEncoding()
            
            if data.blur == true {
                blurKernel.encode(commandBuffer: commandBuffer,
                                  sourceTexture: offscreenRenderTexture,
                                  destinationTexture: blurTexture)
            }
        }
        
        if data.animation == true {
            data.multiplier += data.animationStep
        }
    }
    
    private func encodePointsPass(target buffer: MTLBuffer,
                                  commandBuffer: MTLCommandBuffer,
                                  elementCount: simd_uint1) {
        var pointsCount = elementCount
        
        let fillBufferEncoder = commandBuffer.makeComputeCommandEncoder()
        fillBufferEncoder?.setComputePipelineState(self.computePointsPSO)
        fillBufferEncoder?.label = "Compute Points - Encoder"
        
        fillBufferEncoder?.setBuffer(buffer, offset: 0, index: 0)
        fillBufferEncoder?.setBytes(&pointsCount, length: MemoryLayout<simd_uint1>.stride, index: 1)
        fillBufferEncoder?.setBytes(&data.circleRadius, length: MemoryLayout<simd_float1>.stride, index: 2)
        
        let dispatchSize = getDispatchSize(for: self.computePointsPSO, bufferSize: Int(pointsCount))
        fillBufferEncoder?.dispatchThreads(dispatchSize.0, threadsPerThreadgroup: dispatchSize.1)
        
        fillBufferEncoder?.endEncoding()
    }
    
    private func encodeLinesPass(from pointsBuffer: MTLBuffer,
                                 to linesBuffer: MTLBuffer,
                                 commandBuffer: MTLCommandBuffer,
                                 elementCount: simd_uint1,
                                 multiplier: simd_float1) {
       
        var pointsCount = elementCount
        var multiplier = multiplier
        
        let computeLinesEncoder = commandBuffer.makeComputeCommandEncoder()
        computeLinesEncoder?.setComputePipelineState(self.computeLinesPSO)
        computeLinesEncoder?.label = "Compute Lines - Encoder"
        
        computeLinesEncoder?.setBuffer(pointsBuffer, offset: 0, index: 0)
        computeLinesEncoder?.setBuffer(linesBuffer, offset: 0, index: 1)
        computeLinesEncoder?.setBytes(&pointsCount, length: MemoryLayout<simd_uint1>.stride, index: 2)
        computeLinesEncoder?.setBytes(&multiplier, length: MemoryLayout<simd_float1>.stride, index: 3)
        computeLinesEncoder?.setBytes(&data.circleRadius, length: MemoryLayout<simd_float1>.stride, index: 4)
         
        let dispatchSize = getDispatchSize(for: self.computeLinesPSO, bufferSize: Int(pointsCount))
        computeLinesEncoder?.dispatchThreads(dispatchSize.0, threadsPerThreadgroup: dispatchSize.1)
        
        computeLinesEncoder?.endEncoding()
    }
    
    private func getDispatchSize(for pso: MTLComputePipelineState, bufferSize: Int) -> (MTLSize, MTLSize) {
        var threadGroupSize = pso.maxTotalThreadsPerThreadgroup
        if threadGroupSize > bufferSize {
            threadGroupSize = bufferSize
        }
        
        return ( MTLSize(width: bufferSize, height: 1, depth: 1),
                 MTLSize(width: threadGroupSize, height: 1, depth: 1))
    }

}
