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
    
    public init(with device: MTLDevice, _ data: UIDataObject) {
        self.device = device
        self.data = data
        self.library = Library(with: device,
                               functions: ["animated"])

        guard let texture = makeTextureRenderTarget() else {
            fatalError("[Metal] Error creating render target texture.")
        }
        self.renderTargetTexture = texture
    }
    
    func makeTextureRenderTarget() -> MTLTexture? {
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.height = Int(data.height)
        texDescriptor.width = Int(data.width / 2.0)
        texDescriptor.pixelFormat = .bgra8Unorm_srgb
        texDescriptor.usage = [.renderTarget, .shaderRead]
        texDescriptor.textureType = .type2D
        
        if let texture = device.makeTexture(descriptor: texDescriptor) {
            return texture
        }
        return nil
    }
    
    public func draw(with device: MTLDevice, _ commandBuffer: MTLCommandBuffer) {
        return
    }
}
