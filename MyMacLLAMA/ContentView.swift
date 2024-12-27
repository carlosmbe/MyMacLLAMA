//
//  ContentView.swift
//  MyMacLLAMA
//
//  Created by Carlos Mbendera on 25/04/2024.
//

import SwiftUI

struct ContentView: View {
    
     @EnvironmentObject var appModel: DataInterface
    
    var settingsView: some View{
        HStack{
            Spacer()
            Menu{
                Text("Settings")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Divider()
                Text("Current Model \(appModel.selectedModel)")
                Toggle("Stream Responses", isOn: $appModel.streamResponses)
                
                Divider()
                Button("Exit App"){exit(0)}
            }
            label: {
                 Image(systemName: "gear")
            }
            .fixedSize()
            .menuStyle(.borderlessButton)
            
        }
        .padding()
    }
    
    var textBoxView: some View{
        TextField("Prompt", text: $appModel.prompt)
            .textFieldStyle(.roundedBorder)
            .onSubmit{
                Task{ await appModel.sendPrompt()    }
            }
    }
    
    var buttonsRow: some View{
        HStack{
            Button("Send"){
                Task { await appModel.sendPrompt() }
            }
            .keyboardShortcut(.return)
            .disabled(appModel.isSending)
            
            Button("Clear"){
                appModel.prompt = ""
                appModel.response = ""
            }
            .keyboardShortcut("c")
            .disabled(appModel.isSending)
            
        }
    }
    
    var body: some View {
        VStack {
            
            
            settingsView
            
            textBoxView
            
            Divider()
            
            if appModel.isSending && !appModel.streamResponses {
                ProgressView()
                    .padding()
            }else{
                ScrollView {
                    Text(appModel.response)
                }
            }
            
            if !appModel.isSending{
                buttonsRow
            }
           
          
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}
