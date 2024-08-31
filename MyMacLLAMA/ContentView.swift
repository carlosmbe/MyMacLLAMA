//
//  ContentView.swift
//  MyMacLLAMA
//
//  Created by Carlos Mbendera on 25/04/2024.
//

import SwiftUI

struct ContentView: View {
    
    // I will use the EnvironmentObject property wrapper to share data between this view and others
     @EnvironmentObject var appModel: DataInterface
    
    var body: some View {
        VStack {
            
            // TextField for the user input .
            TextField("Type Prompt Here", text: $appModel.prompt)
                .textFieldStyle(.roundedBorder)
                .onSubmit{
                    appModel.sendPrompt() // Send the prompt to Ollama and get a response
                    appModel.prompt = "" //Clears the Text Field after submiting
                }
            // Divider draws a line separating elements
            Divider()
            
            // Use an if statement to conditionally display a view depending on if appModel.isSending.
            if appModel.isSending{
                ProgressView() // Display a progress bar while waiting for a response.
                    .padding()
            }else{
                ScrollView { // Allows the response to scroll
                    Text(appModel.response) // Display the response text from appModel if not currently sending.
                }
            }
            
           
            HStack{
                
                // Button to send the current prompt. It triggers the sendPrompt function when clicked.
                Button("Send"){
                    appModel.sendPrompt()
                }
                .keyboardShortcut(.return) // Assign the return key as a shortcut to activate this button. Cause Mac.
                
                // Button to clear the current prompt and response.
                Button("Clear"){
                    appModel.prompt = "" // Clear the prompt string.
                    appModel.response = "" // Clear the response string.
                }
                .keyboardShortcut("c") // Assign the 'c' key as a shortcut to activate this button. So Command + C
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
