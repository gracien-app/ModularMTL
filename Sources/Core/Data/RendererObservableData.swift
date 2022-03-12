//
//  RendererObservableData.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI

public class RendererObservableData: ObservableObject {
    
    public init() {}
    
    @Published public var pointsCount: UInt = 100
    @Published public var multiplier: Float = 2
    
    public var circleRadius: Float = 0.85
    public let animationStep: Float = 0.005
    public let targetFPS: Int = 60
    private let resolution: (CGFloat, CGFloat) = (1300, 650)
    
    public var animation: Bool = false
    public var showAlert: Bool = false
    public var blur: Bool = true
    
    @Published public var frametime: Double = 0
    
    @Published public var status: MetalFeatureStatus = .Full  {
        didSet {
            switch status {
                case .Full:
                    showAlert = false
                    break
                default:
                    showAlert = true
                    blur = false
                    break
            }
        }
    }
    
    public var error: Error? {
        didSet {
            status = .FatalError
        }
    }
}


public extension RendererObservableData {
    func averageFrametime(new value: Double) {
        let average = (value + frametime) / 2.0
        frametime = average
    }
    
    func getAlertMessage() -> String {
        if let error = error {
            return "\(error)"
        }
        else {
            return status.rawValue
        }
    }

    var width: CGFloat {
        return resolution.0
    }

    var height: CGFloat {
        return resolution.1
    }
    
    var frametimeInMs: String {
        return String(format: "%.1f", frametime) + "ms"
    }
    
    enum MetalFeatureStatus: String {
        case Full = "Full application functionality."
        case Limited = "Your device does not support required Metal API feature set.\n\n Application functionality is reduced."
        case FatalError = "Your device does not support Metal API."
    }
}
