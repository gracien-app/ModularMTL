//
//  UserInterfaceView.swift
//  
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI
import ModularMTLCore

struct UserInterfaceView: View {
    
    @EnvironmentObject var data: UIDataObject
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 25) {
                MenuTextView(label: "MULTIPLY", String(format: "%.2f", data.multiplier))
                MenuTextView(label: "OFFSET", String(format: "%.3f", data.animationStep))
                MenuTextView(label: "DISPERSAL", String(format: "%u", data.pointsCount))
                MenuTextView(label: "U")
                MenuTextView(label: "LATENCY", data.frametimeInMs)
                MenuTextView(label: "ANIMATE", nil, dataBinding: $data.animation)
                MenuTextView(label: "RADIUS", String(format: "%.2f", data.circleRadius))
            }
        }
    }
}
