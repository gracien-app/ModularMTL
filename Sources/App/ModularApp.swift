//
//  ModularApp.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI

@main
struct ModularMTLApp: App {
    
    #if os(macOS)
        @NSApplicationDelegateAdaptor(ModularAppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
    #endif
    }
}
