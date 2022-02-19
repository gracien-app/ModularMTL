//
//  UIDataObject.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI

public class UIDataObject: ObservableObject {
    
    public init() {}
    
    @Published public var frametime: Double = 0
    @Published public var pointsCount: UInt = 100
    @Published public var multiplier: Float = 2
    @Published public var animation: Bool = false
    @Published public var blur: Bool = true
   
    var resolution: (CGFloat, CGFloat) = (1300, 650)
    
    public let targetFPS: Int = 60
    public let sampleCount: Int = 1
    public var circleRadius: Float = 0.85
    public let animationStep: Float = 0.005
    
    public var width: CGFloat {
        return resolution.0
    }

    public var height: CGFloat {
        return resolution.1
    }
    
    public var frametimeInMs: String {
        return String(format: "%.1f", frametime) + "ms"
    }
}
