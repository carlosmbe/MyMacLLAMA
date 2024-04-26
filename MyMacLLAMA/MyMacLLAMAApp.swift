//
//  MyMacLLAMAApp.swift
//  MyMacLLAMA
//
//  Created by Carlos Mbendera on 25/04/2024.
//

import SwiftUI

@main
struct MyMacLLAMAApp: App {
    var body: some Scene {
        
        @StateObject var appModel = DataInterface()
        
        /*
        WindowGroup {
            ContentView()
        }
        */
        
        MenuBarExtra("My Mac LLAMA Bar", systemImage: "brain"){
            ContentView()
                .environment(appModel)

        }
        .menuBarExtraStyle(.window)
        
        
    }
}
