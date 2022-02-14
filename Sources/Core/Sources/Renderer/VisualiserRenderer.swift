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
    var pointsBuffer: PointsBuffer<simd_float2>
    
    public init(with device: MTLDevice, _ data: UIDataObject) {
        self.device = device
        self.data = data
        self.library = Library(with: device,
                               functions: ["animated"])

        guard let texture = TextureManager.getTexture(with: device,
                                                      format: .bgra8Unorm_srgb,
                                                      sizeWH: (Int(data.width / 2.0), Int(data.height)),
                                                      type: .renderTarget)
        else {
            fatalError("[Metal] Error creating render target texture.")
        }
        
        self.renderTargetTexture = texture
        self.pointsBuffer = PointsBuffer(with: device, size: data.pointsCount)
    }
    
    public func draw(with device: MTLDevice, _ commandBuffer: MTLCommandBuffer) {
        pointsBuffer.updateStatus(points: data.pointsCount)
        return
    }
}
