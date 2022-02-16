//
//  CustomMTKView.swift
//  
//
//  Created by Gracjan J on 13/02/2022.
//

import MetalKit
import ModularMTLCore

class CustomMTKView: MTKView {
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        Keyboard.SetKeyPressed(event.keyCode, isOn: true)
    }
    
    override func keyUp(with event: NSEvent) {
        Keyboard.SetKeyPressed(event.keyCode, isOn: false)
    }
}
