//
//  UserInterfaceView.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI
import ModularMTLCore

struct UserInterfaceView: View {
    
    @EnvironmentObject var data: RendererObservableData
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 25) {
                
                MenuTextView(label: "MULTIPLE",  data.getDataString(type: .M))
                
                MenuTextView(label: "OFFSET",    data.getDataString(type: .OFFSET))
                
                MenuTextView(label: "DISPERSAL", data.getDataString(type: .N))
                
                MenuTextView(label: "U")
                
                MenuTextView(label: "LATENCY",   data.getDataString(type: .FRAMETIME))
                
                MenuTextView(label: "ANIMATE",   nil, dataBinding: $data.animation)
                
                MenuTextView(label: "RADIATE",   nil, dataBinding: $data.blurEnabled, isDisabled: data.status == .Limited ? true : false)
                
            }
        }
    }
}
