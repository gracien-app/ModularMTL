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
        VStack(alignment: .center, spacing: 20) {
            Text("MODULAR")
                .font(.system(size: 40))
                .fontWeight(.ultraLight)
                .tracking(40)
            
            Text("N: \(data.pointsCount)")
                .font(.system(size: 30))
                .fontWeight(.ultraLight)
                .tracking(5)
            
            Text("M: \(String(format: "%.2f", data.multiplier))")
                .font(.system(size: 30))
                .fontWeight(.ultraLight)
                .tracking(5)
            
            Toggle(isOn: $data.animation, label: {
                Text("Animation")
                    .font(.system(size: 15))
                    .fontWeight(.ultraLight)
                    .tracking(5)
                
            })
                .toggleStyle(.switch)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
}
