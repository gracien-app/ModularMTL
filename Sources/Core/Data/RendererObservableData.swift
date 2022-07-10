//
//  RendererObservableData.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI

public class RendererObservableData: ObservableObject {
    
    public init() {}
    
    @Published public var pointsCount: UInt = 200
    @Published public var multiplier: Float = 1.5
    @Published public var frametime: Double = 0
    
    public var circleRadius: Float = 0.85
    public let animationStep: Float = 0.005
    public let targetFPS: Int = 60
    private let resolution: (CGFloat, CGFloat) = (1300, 650)
    
    public var animation: Bool = false
    public var showAlert: Bool = false
    public var blurEnabled: Bool = true
    public var upscalingEnabled: Bool = false
    
    
    @Published public var status: MetalFeatureStatus = .Full  {
        didSet {
            switch status {
                case .Full:
                    showAlert = false
                    break
                default:
                    showAlert = true
                    blurEnabled = false
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
    
    
    var renderAreaWidth: CGFloat {
        return (width / 2.0) + 28
    }
    
    
    var renderAreaHeight: CGFloat {
        return height + 28
    }
    
    // Base render resulution.
    var baseResolution: (Int, Int) {
        return (Int(renderAreaWidth * 2), Int(renderAreaHeight * 2))
    }
    
    // Upscaling factor
    var upscalingFactor: Int {
        return 2
    }
    
    // Resolution with upscaling factor taken into account
    var upscaledResolution: (Int, Int) {
        return (baseResolution.0 * upscalingFactor, baseResolution.1 * upscalingFactor)
    }
    
    
    func getDataString(type: DataStringType) -> String {
        switch type {
            case .N:
                return String(format: "%u", self.pointsCount)
            case .M:
                return String(format: "%.2f", self.multiplier)
            case .OFFSET:
                return String(format: "%.3f", self.animationStep)
            case .FRAMETIME:
                return String(format: "%.1f", frametime) + "ms"
        }
    }
    

    enum MetalFeatureStatus: String {
        case Full = "Full application functionality."
        case Limited = "Your device does not support required Metal API feature set.\n\n Application functionality is reduced."
        case FatalError = "Your device does not support Metal API."
    }
    
    
    enum DataStringType {
        case M
        case N
        case OFFSET
        case FRAMETIME
    }
}
