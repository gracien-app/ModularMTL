//
//  ModularRenderer+Extensions.swift
//  
//
//  Created by Gracjan J on 09/03/2022.
//

import Foundation
import MetalKit

extension ModularRenderer {
    
    // MARK: - Public extensions
    public func adjustPointCount(by offset: Int) {
        let newCount = Int(data.pointsCount) + offset
        if newCount > 2 {
            data.pointsCount = UInt(newCount)
        }
        else {
            data.pointsCount = 2
        }
    }
    
    
    public func adjustMultiplier(by offset: Float) {
        data.multiplier += offset
    }
    
    
    public func encodeDrawToView(to commandBuffer: MTLCommandBuffer,
                                 with descriptor: MTLRenderPassDescriptor) {
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        
        renderEncoder.setRenderPipelineState(self.drawInViewPSO)
        renderEncoder.setFragmentTexture(self.renderTargetTexture, index: 0)
        renderEncoder.setFragmentTexture(self.blurTexture, index: 1)
        renderEncoder.setFragmentBytes(&data.blurEnabled, length: MemoryLayout<uint8>.stride, index: 0)
        renderEncoder.setFragmentBytes(&data.multiplier, length: MemoryLayout<simd_float1>.stride, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
    }

    
    public func encodeDraw(to commandBuffer: MTLCommandBuffer) {
        let tempN = simd_uint1(data.pointsCount)
        let tempM = data.multiplier
        
        linesBuffer.updateStatus(points: UInt(tempN), multiplier: tempM)
        
        if linesBuffer.isValid == false {
            encodeLinesPass(storage: linesBuffer.contents(),
                            commandBuffer: commandBuffer,
                            elementCount: tempN,
                            multiplier: tempM)
            
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: self.offscreenRenderPD)!
            renderEncoder.setRenderPipelineState(offscreenRenderPSO)
            renderEncoder.setVertexBuffer(linesBuffer.contents(), offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: Int(tempN*2))
            renderEncoder.endEncoding()
            
            if data.blurEnabled {
                blurKernel.encode(commandBuffer: commandBuffer,
                                  sourceTexture: renderTargetTexture,
                                  destinationTexture: blurTexture)
            }
        }
        
        if data.animation == true {
            data.multiplier += data.animationStep
        }
    }
    
    
    // MARK: - Private extensions
    private func encodeLinesPass(storage linesBuffer: MTLBuffer,
                                 commandBuffer: MTLCommandBuffer,
                                 elementCount: simd_uint1,
                                 multiplier: simd_float1) {
       
        var pointsCount = elementCount
        var multiplier = multiplier
        
        let computeLinesEncoder = commandBuffer.makeComputeCommandEncoder()
        computeLinesEncoder?.setComputePipelineState(self.computeLinesPSO)
        computeLinesEncoder?.label = "Compute Lines - Pass"
        
        computeLinesEncoder?.setBuffer(linesBuffer, offset: 0, index: 0)
        computeLinesEncoder?.setBytes(&pointsCount, length: MemoryLayout<simd_uint1>.stride, index: 1)
        computeLinesEncoder?.setBytes(&multiplier, length: MemoryLayout<simd_float1>.stride, index: 2)
        computeLinesEncoder?.setBytes(&data.circleRadius, length: MemoryLayout<simd_float1>.stride, index: 3)
         
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
