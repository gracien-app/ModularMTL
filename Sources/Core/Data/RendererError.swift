//
//  RendererError.swift
//  
//
//  Created by Gracjan Jeżewski on 12/03/2022.
//

import Foundation

public enum RendererError: LocalizedError {
    
    case PipelineCreationError(Details: String)
    case BufferCreationError(Details: String)
    case TextureCreationError(Details: String)
    case LibraryCreationError(Details: String)
    case UnsupportedDevice(Details: String)
    case FatalError(Details: String)
    
}
