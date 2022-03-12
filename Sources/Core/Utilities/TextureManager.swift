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
                                  type: TextureType,
                                  label: String? = nil) -> Result<MTLTexture, RendererError> {
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = sizeWH.0
        texDescriptor.height = sizeWH.1
        texDescriptor.pixelFormat = format
        texDescriptor.textureType = .type2D
        
        switch type {
            case .renderTarget:
                texDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
                texDescriptor.storageMode = .private
            case .readWrite:
                texDescriptor.usage = [.shaderRead, .shaderWrite]
            case .writeOnly:
                texDescriptor.usage = [.shaderWrite]
            case .readOnly:
                texDescriptor.usage = [.shaderRead]
        }
        
        guard let texture = device.makeTexture(descriptor: texDescriptor) else {
            let detailLabel = label ?? "Unlabeled texture"
            return .failure(.TextureCreationError(Details: "\(detailLabel)"))
        }
        
        if let label = label {
            texture.label = label
        }
        
        return .success(texture)
    }
    
}
