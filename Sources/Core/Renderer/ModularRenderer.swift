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
    
    var device: MTLDevice!
    public var data: RendererObservableData
    public var library: Library!
    
    var pointsBuffer: ManagedBuffer<simd_float2>!
    var linesBuffer: ManagedBuffer<simd_float4>!
    
    var blurKernel: MPSUnaryImageKernel!
    
    var offscreenRenderPD: MTLRenderPassDescriptor!
    
    var blurTexture: MTLTexture!
    var renderTargetTexture: MTLTexture!
    
    var drawInViewPSO: MTLRenderPipelineState!
    var computeLinesPSO: MTLComputePipelineState!
    var computePointsPSO: MTLComputePipelineState!
    var offscreenRenderPSO: MTLRenderPipelineState!
    
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
    
    
    // MARK: - Init methods
    public init?(with data: RendererObservableData, device: MTLDevice) throws {
        self.data = data
        self.device = device
        
        let result = Helper.merge({ self.prepareDevice()    },
                                  { self.prepareBuffers()   },
                                  { self.prepareLibrary()   },
                                  { self.preparePipelines() },
                                  { self.prepareTextures()  })
        
        switch result {
            case .success():
                return
            case .failure(let error):
                throw error
        }
    }
    
    
    private func prepareDevice() -> Result<Void, RendererError> {
        if device.supportsFamily(.apple7) {
            self.blurKernel = MPSImageGaussianBlur(device: device, sigma: 55)
        }
        else {
            data.status = .Limited
        }
        return .success(Void())
    }
    
    
    private func prepareLibrary() -> Result<Void, RendererError> {
        let functionsList = [
            "computePointsFunction", "computeLinesFunction",
            "fragmentFunction", "linesVertexFunction",
            "quadFragmentFunction", "quadVertexFunction",
        ]
        
        do {
            self.library = try Library(with: device, functions: functionsList)
        }
        catch let error as RendererError {
            return .failure(error)
        }
        catch {
            return .failure(.LibraryCreationError(Details: "Unknown error."))
        }
        
        return .success(Void())
    }
    
    
    private func prepareBuffers() -> Result<Void, RendererError> {
        let minimumSize: UInt = 200
        
        do {
            self.pointsBuffer = try ManagedBuffer(with: device,
                                                  count: data.pointsCount,
                                                  minimum: minimumSize,
                                                  label: "PointsBuffer")
            
            self.linesBuffer = try ManagedBuffer(with: device,
                                                 count: data.pointsCount,
                                                 minimum: minimumSize,
                                                 label: "LinesBuffer")
        }
        catch let error as RendererError {
            return .failure(error)
        }
        catch {
            return .failure(.BufferCreationError(Details: "Unknown error."))
        }
    
        return .success(Void())
    }
    
    
    private func preparePipelines() -> Result<Void, RendererError> {
        do {
            let offscreenRPD = MTLRenderPipelineDescriptor()
            offscreenRPD.vertexFunction = try library.createFunction(name: "linesVertexFunction").get()
            offscreenRPD.fragmentFunction = try library.createFunction(name: "fragmentFunction").get()
            offscreenRPD.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
            
            let quadRPD = MTLRenderPipelineDescriptor()
            quadRPD.vertexFunction = try library.createFunction(name: "quadVertexFunction").get()
            quadRPD.fragmentFunction = try library.createFunction(name: "quadFragmentFunction").get()
            quadRPD.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
            
            self.offscreenRenderPSO = try device.makeRenderPipelineState(descriptor: offscreenRPD)
            self.drawInViewPSO = try device.makeRenderPipelineState(descriptor: quadRPD)
            
            let computePointsFunction = try library.createFunction(name: "computePointsFunction").get()
            self.computePointsPSO = try device.makeComputePipelineState(function: computePointsFunction)
            
            let computeLinesFunction = try library.createFunction(name: "computeLinesFunction").get()
            self.computeLinesPSO = try device.makeComputePipelineState(function: computeLinesFunction)
        }
        catch let error as RendererError {
            return .failure(error)
        }
        catch {
            return .failure(.PipelineCreationError(Details: "Unknown error."))
        }
        
        return .success(Void())
    }
    
    
    private func prepareTextures() -> Result<Void, RendererError> {
        let renderTargetTextureResult = TextureManager.getTexture(with: device,
                                                           format: .bgra8Unorm_srgb,
                                                           sizeWH: (Int(data.width / 2.0 + 28) * 2, Int(data.height + 28) * 2),
                                                           type: .renderTarget,
                                                           label: "RenderTargetTexture")
        
        let blurTextureResult = TextureManager.getTexture(with: device,
                                                          format: .bgra8Unorm_srgb,
                                                          sizeWH: (Int(data.width / 2.0 + 28) * 2, Int(data.height + 28) * 2),
                                                          type: .readWrite,
                                                          label: "BlurTexture")
        
        do {
            self.blurTexture = try blurTextureResult.get()
            self.renderTargetTexture = try renderTargetTextureResult.get()
        }
        catch let error as RendererError {
            return .failure(error)
        }
        catch {
            return .failure(.TextureCreationError(Details: "Unknown error."))
        }
        
        self.offscreenRenderPD = MTLRenderPassDescriptor()
        self.offscreenRenderPD.colorAttachments[0].texture = self.renderTargetTexture
        self.offscreenRenderPD.colorAttachments[0].loadAction = .clear
        self.offscreenRenderPD.colorAttachments[0].storeAction = .store
        self.offscreenRenderPD.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        return .success(Void())
    }
}
