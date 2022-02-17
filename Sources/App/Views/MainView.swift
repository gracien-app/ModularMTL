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
            Color.black
                .ignoresSafeArea()
            
            HStack(alignment: .center, spacing: 5) {
                MetalView()
                    .frame(maxWidth: .infinity)
                UserInterfaceView()
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .environmentObject(data)
        .frame(width: data.width, height: data.height, alignment: .center)
    }
}
