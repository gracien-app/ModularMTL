//
//  VisualiserRenderer.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import Foundation
import MetalKit

public class VisualiserRenderer: Renderer {
    
    var device: MTLDevice
    var renderTargetTexture: MTLTexture?
    
    var data: UIDataObject
    var library: Library
    
    var pointsBuffer: ManagedBuffer<simd_float2>
    var linesBuffer: ManagedBuffer<simd_float4>
    
    let fillBufferPSO: MTLComputePipelineState
    let fillStaticPSO: MTLComputePipelineState
    let fillAnimatedPSO: MTLComputePipelineState
    
    let renderPassPSO: MTLRenderPipelineState
    
    public init(with device: MTLDevice, _ data: UIDataObject) {
        self.device = device
        self.data = data
        self.library = Library(with: device,
                               functions: ["fillPointsBuffer", "fillAnimatedLines", "fillStaticLines",
                                           "fragmentFunction", "pointsVertexFunction", "linesVertexFunction"])

        guard let texture = TextureManager.getTexture(with: device,
                                                      format: .bgra8Unorm_srgb,
                                                      sizeWH: (Int(data.width / 2.0), Int(data.height)),
                                                      type: .renderTarget)
        else {
            fatalError("[Metal] Error creating render target texture.")
        }
        
        self.renderTargetTexture = texture
        
        let minimum = UInt(500)
        self.pointsBuffer = ManagedBuffer(with: device, count: data.pointsCount, minimum: minimum)
        self.linesBuffer = ManagedBuffer(with: device, count: data.pointsCount, minimum: minimum)
        
        do {
            self.fillBufferPSO = try device.makeComputePipelineState(function: library.getFunction(name: "fillPointsBuffer")!)
            self.fillStaticPSO = try device.makeComputePipelineState(function: library.getFunction(name: "fillStaticLines")!)
            self.fillAnimatedPSO = try device.makeComputePipelineState(function: library.getFunction(name: "fillAnimatedLines")!)
            
            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
            renderPipelineDescriptor.vertexFunction = library.getFunction(name: "linesVertexFunction")
            renderPipelineDescriptor.fragmentFunction = library.getFunction(name: "fragmentFunction")
            renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
            renderPipelineDescriptor.sampleCount = data.sampleCount
            renderPassPSO = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error)
            fatalError("[Metal] Error creating PSO.")
        }
    }
    
    private func encodeFillBuffer(target buffer: MTLBuffer,
                                  commandBuffer: MTLCommandBuffer,
                                  elementCount: simd_uint1) {
        var pointsCount = elementCount
        let fillBufferEncoder = commandBuffer.makeComputeCommandEncoder()
        fillBufferEncoder?.setComputePipelineState(self.fillBufferPSO)
        fillBufferEncoder?.label = "fillBuffer Compute CE"
        fillBufferEncoder?.setBytes(&pointsCount, length: MemoryLayout<simd_uint1>.stride, index: 0)
        fillBufferEncoder?.setBytes(&data.circleRadius, length: MemoryLayout<simd_float1>.stride, index: 1)
        fillBufferEncoder?.setBuffer(buffer, offset: 0, index: 2)
        var threadGroupSize = self.fillBufferPSO.maxTotalThreadsPerThreadgroup
        if threadGroupSize > pointsCount {
            threadGroupSize = Int(pointsCount)
        }
        fillBufferEncoder?.dispatchThreads(MTLSize(width: Int(pointsCount), height: 1, depth: 1),
                                           threadsPerThreadgroup: MTLSize(width: threadGroupSize, height: 1, depth: 1))
        fillBufferEncoder?.endEncoding()
    }
    
    private func encodeFillLinesBuffer(from pointsBuffer: MTLBuffer,
                                       to linesBuffer: MTLBuffer,
                                       commandBuffer: MTLCommandBuffer,
                                       elementCount: simd_uint1,
                                       animated: Bool) {
       
        var pointsCount = elementCount
        let fillBufferEncoder = commandBuffer.makeComputeCommandEncoder()
        fillBufferEncoder?.setBytes(&pointsCount, length: MemoryLayout<simd_uint1>.stride, index: 0)
        fillBufferEncoder?.setBuffer(pointsBuffer, offset: 0, index: 2)
        fillBufferEncoder?.setBuffer(linesBuffer, offset: 0, index: 3)
        fillBufferEncoder?.label = animated ? "fillAnimated Compute CE" : "fillStatic Compute CE"
       
        if animated {
            fillBufferEncoder?.setComputePipelineState(self.fillAnimatedPSO)
            fillBufferEncoder?.setBytes(&data.multiplier, length: MemoryLayout<simd_float1>.stride, index: 1)
        }
        else {
            fillBufferEncoder?.setComputePipelineState(self.fillStaticPSO)
            var integerM = simd_uint1(data.multiplier.rounded())
            fillBufferEncoder?.setBytes(&integerM, length: MemoryLayout<simd_uint1>.stride, index: 1)
        }
        
        var threadGroupSize = self.fillBufferPSO.maxTotalThreadsPerThreadgroup
        if threadGroupSize > pointsCount {
            threadGroupSize = Int(pointsCount)
        }
        fillBufferEncoder?.dispatchThreads(MTLSize(width: Int(pointsCount), height: 1, depth: 1),
                                           threadsPerThreadgroup: MTLSize(width: threadGroupSize, height: 1, depth: 1))
        fillBufferEncoder?.endEncoding()
    }
    
    public func draw(with device: MTLDevice, _ commandBuffer: MTLCommandBuffer, _ viewRPD: MTLRenderPassDescriptor) {
        let pointsCount = simd_uint1(data.pointsCount)
        pointsBuffer.updateStatus(points: UInt(pointsCount))
        
        if pointsBuffer.isValid == false {
            encodeFillBuffer(target: self.pointsBuffer.contents(),
                             commandBuffer: commandBuffer,
                             elementCount: pointsCount)
            
            encodeFillLinesBuffer(from: pointsBuffer.contents(),
                                  to: linesBuffer.contents(),
                                  commandBuffer: commandBuffer,
                                  elementCount: pointsCount,
                                  animated: false)
        }
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: viewRPD)!
        
        renderEncoder.setRenderPipelineState(renderPassPSO)
        renderEncoder.setVertexBuffer(linesBuffer.contents(), offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: Int(pointsCount*2))
        renderEncoder.endEncoding()
        
        return
    }
}
