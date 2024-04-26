//
//  ContentView.swift
//  MyMacLLAMA
//
//  Created by Carlos Mbendera on 25/04/2024.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appModel: DataInterface
    
    var body: some View {
        VStack {
            
            TextField("Prompt", text: $appModel.prompt)
                .textFieldStyle(.roundedBorder)
                .onSubmit(appModel.sendPrompt)
            
            
            Divider()
            
            if appModel.isSending{
                ProgressView()
                    .padding()
            }else{
                Text(appModel.response)
            }
            
            HStack{
                
                Button("Send"){
                    appModel.sendPrompt()
                }
                .keyboardShortcut(.return)
                
                Button("Clear"){
                    appModel.prompt = ""
                    appModel.response = ""
                }
                .keyboardShortcut("c")
                
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
