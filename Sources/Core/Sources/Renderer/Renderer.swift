//
//  Renderer.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import Foundation
import MetalKit

protocol Renderer {
    var device: MTLDevice { get set }
    func draw(with device: MTLDevice, _ commandBuffer: MTLCommandBuffer)
}
