//
//  Library.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import Foundation
import MetalKit

public class Library {
    
    // MARK: - Parameters
    private var metalLibrary: MTLLibrary!
    private var mtlFunctions: [String: MTLFunction] = [:]
    
    // MARK: - Methods
    public init?(with device: MTLDevice, functions: [String]) throws {
        
        switch loadDefaultLibrary(device) {
            case .success(let library):
                self.metalLibrary = library
            case .failure(let error):
                throw error
        }
        
        for function in functions {
            switch createFunction(name: function) {
                case .failure(let error):
                    throw error as RendererError
                default:
                    break
            }
        }
    }
    
    
    public func getFunction(name: String) -> MTLFunction? {
        if let function = mtlFunctions[name] {
            return function
        }
        return nil
    }
    
    
    public func createFunction(name: String) -> Result<MTLFunction, RendererError> {
        if let function = mtlFunctions[name] {
            return .success(function)
        }
        else {
            if let function = metalLibrary.makeFunction(name: name) {
                function.label = name
                mtlFunctions[name] = function
                return .success(function)
            }
            return .failure(.LibraryCreationError(Details: "Unable to create function: \(name)"))
        }
    }
    
    
    func loadDefaultLibrary(_ device: MTLDevice) -> Result<MTLLibrary, RendererError> {
        let path = "Contents/Resources/ModularMTL_ModularMTLCore.bundle"
       
        guard let bundle = Bundle(url:Bundle.main.bundleURL.appendingPathComponent(path)) else {
            return .failure(.LibraryCreationError(Details: "Unable to find bundle at \(path)"))
        }
      
        do {
            return .success(try device.makeDefaultLibrary(bundle: bundle))
        } catch {
            return .failure(.LibraryCreationError(Details: "Unable to create default Metal library from bundle."))
        }
    }
}
