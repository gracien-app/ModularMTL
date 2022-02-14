//
//  TextureManager.swift
//  
//
//  Created by Gracjan J on 14/02/2022.
//

import Foundation
import Metal

public enum TextureType {
    case renderTarget
    case readWrite
    case readOnly
    case writeOnly
}

public enum TextureManager {
    
    public static func getTexture(with device: MTLDevice,
                                  format: MTLPixelFormat,
                                  sizeWH: (Int, Int),
                                  type: TextureType) -> MTLTexture? {
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = sizeWH.0
        texDescriptor.height = sizeWH.1
        texDescriptor.pixelFormat = format
        texDescriptor.textureType = .type2D
        
        switch type {
            case .renderTarget:
                texDescriptor.usage = [.renderTarget, .shaderRead]
            case .readWrite:
                texDescriptor.usage = [.shaderRead, .shaderWrite]
            case .writeOnly:
                texDescriptor.usage = [.shaderWrite]
            case .readOnly:
                texDescriptor.usage = [.shaderRead]
        }
        
        if let texture = device.makeTexture(descriptor: texDescriptor) {
            return texture
        }
        return nil
    }
}
