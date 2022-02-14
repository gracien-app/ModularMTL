//
//  MainView.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI
import ModularMTLCore

struct MainView: View {
    
    @StateObject var data = UIDataObject()
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                MetalView()
                    .frame(maxWidth: .infinity)
                UserInterfaceView()
                    .frame(maxWidth: .infinity)
            }
        }
        .environmentObject(data)
        .frame(width: data.width, height: data.height, alignment: .center)
    }
}
