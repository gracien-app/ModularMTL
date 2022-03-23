//
//  MainView.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI
import ModularMTLCore

struct MainView: View {
    
    @StateObject var data = RendererObservableData()
    
    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()
            
            HStack(alignment: .center, spacing: 5) {
                MetalView()
                    .frame(width: data.renderAreaWidth, height: data.renderAreaHeight)
                UserInterfaceView()
                    .frame(maxWidth: .infinity)
            }
            .environmentObject(data)
            .ignoresSafeArea(.all, edges: .top)
            .alert("ModularMTL",
                   isPresented: $data.showAlert,
                   actions: { Button("Confirm") { if data.status == .FatalError { exit(1) }} },
                   message: { Text(data.getAlertMessage()) }
            )
        }
        .frame(width: data.width, height: data.height, alignment: .center)
    }
}
