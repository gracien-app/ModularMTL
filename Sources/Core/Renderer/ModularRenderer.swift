//
//  ModularRenderer.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import Foundation
import MetalKit
import MetalPerformanceShaders

public class ModularRenderer {
    
    var device: MTLDevice
    public var data: RendererObservableData
    public var library: Library
    
    var pointsBuffer: ManagedBuffer<simd_float2>
    var linesBuffer: ManagedBuffer<simd_float4>
    
    var offscreenRenderTexture: MTLTexture
    
    var blurTexture: MTLTexture
    var blurKernel: MPSUnaryImageKernel
    
    let offscreenRenderPD: MTLRenderPassDescriptor
    let offscreenRenderPSO: MTLRenderPipelineState
    
    let computeLinesPSO: MTLComputePipelineState
    let computePointsPSO: MTLComputePipelineState
    
    var M: Float!
    var linesValid: Bool = true
    
    var currentMultiplier: Float {
        get {
            return M
        }
        set {
            linesValid = newValue == M ? true : false
            M = newValue
        }
    }
    
    public init?(with device: MTLDevice, _ data: RendererObservableData) {
        self.device = device
        
        if !device.supportsFamily(.apple7) {
            data.status = .Limited
        }
        
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

}
