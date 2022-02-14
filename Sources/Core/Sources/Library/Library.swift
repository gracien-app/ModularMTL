//
//  Library.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import Foundation
import MetalKit

public class Library {
    
    private var metalLibrary: MTLLibrary!
    private var mtlFunctions: [String: MTLFunction] = [:]
    
    public init(with device: MTLDevice, functions: [String]) {
        metalLibrary = loadDefaultLibrary(device)!
        
        guard let library = loadDefaultLibrary(device) else {
            fatalError("[Metal] Unable to create default Metal library.")
        }
        self.metalLibrary = library
        
        for function in functions {
            mtlFunctions[function] = metalLibrary.makeFunction(name: function)
            mtlFunctions[function]?.label = function.uppercased()
        }
    }
    
    public func getFunction(name: String) -> MTLFunction? {
        if let function = mtlFunctions[name] {
            return function
        }
        return nil
    }
    
    func loadDefaultLibrary(_ device: MTLDevice) -> MTLLibrary? {
        let path = "Contents/Resources/ModularMTLCore_ModularMTLCore.bundle"
        guard let bundle = Bundle(url:Bundle.main.bundleURL.appendingPathComponent(path)) else {
          fatalError("[Metal] Error accessing internal ModularMTLCore bundle. Unable to load metallib.")
        }
      
        do {
            return try device.makeDefaultLibrary(bundle: bundle)
        } catch {
            return nil
        }
    }
}
