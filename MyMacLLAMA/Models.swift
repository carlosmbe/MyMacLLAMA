//
//  Models.swift
//  MyMacLLAMA
//
//  Created by Carlos Mbendera on 25/04/2024.
//

import Foundation

// Struct to decode the JSON response
struct Response: Codable {
    let model: String
    let response: String
}

// Class for managing application data and network communication
class DataInterface: ObservableObject, Observable {
    
    // Store the current prompt as a modifiable string
    @Published var prompt: String = ""
    // Store the response to the prompt as a modifiable string
    @Published var response: String = ""
    // Track whether a network request is currently being sent
    @Published var isSending: Bool = false
    @Published var streamResponses = false

    @Published var model : String = ""
    @Published var localModels: [LocalModel] = []
    @Published var selectedModel : String = "llama3"
    
    
    ///Function to get a list of models installed
    func getModels() async {
        
        let urlString = "http://127.0.0.1:11434/api/tags"
                guard let url = URL(string: urlString) else { return }
                
                do {
                
                    let (data, _) = try await URLSession.shared.data(from: url)
                
                    let decoded = try JSONDecoder().decode(LocalModelsResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.localModels = decoded.models
                    }
                } catch {
                    print("Failed to fetch or decode /api/tags: \(error)")
                }
        
    }
    
    /// Functions to handle sending the prompt to a server
    func sendPrompt() async {
        // print("Started Send Prompt")  // Log the start of sending a prompt
        
        // Prevent sending if the prompt is empty or a request is already in progress
        guard !prompt.isEmpty, !isSending else { return }
        
        DispatchQueue.main.async {
            self.isSending = true  // Mark that a sending process has started, used for progress bar
        }
        // Define the server endpoint
        let urlString = "http://127.0.0.1:11434/api/generate"
        
        // Safely unwrap the URL constructed from the urlString
        guard let url = URL(string: urlString) else { return }
        
        // Prepare the network request with the URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // Set the HTTP method to POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")  // Set the content type to JSON
        let body: [String: Any] = [
            "model": selectedModel,  // Specify the model to be used
            "prompt": prompt,  // Pass the prompt
            "options": [
                "num_ctx": 4096  // Specify context options
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        await streamResponses ? sendWithStream(request) : sendWithProgressBar(request)
        
    }
    
    func sendWithStream(_ request : URLRequest) async {
        ///Special Shout Out to @Zach Waugh's article on streaming LLM Responses to SwiftUI Text
        ///https://zachwaugh.com/posts/streaming-messages-chatgpt-swift-asyncsequence
        
        //TODO: Make this function able to handle Timed Out API Calls 
        let (stream, _) = try! await URLSession.shared.bytes(for: request)
        do{
            for try await line in stream.lines {
             //   print(line)
                DispatchQueue.main.async {
                    self.response += self.parse(line) ?? ""
                }
            }
        }catch{
            print("Error When Streaming")
        }
        DispatchQueue.main.async {
            self.isSending = false
            self.prompt = ""
        }
    }
    
    func sendWithProgressBar(_ request : URLRequest)  async {
        // Start the data task with the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { self.isSending = false; self.prompt = ""} }  // Ensure isSending is reset after operation
            if let error = error {
                DispatchQueue.main.async { self.response = "Error: \(error.localizedDescription)" }  // Handle errors by updating the response
                return
            }

            // Ensure data was received
            guard let data = data else {
                DispatchQueue.main.async { self.response = "No data received" }  // Handle the absence of data
                return
            }

            let decoder = JSONDecoder()  // Initialize JSON decoder
            let lines = data.split(separator: 10)  // Split the data into lines
            var responses = [String]()  // Array to hold the decoded responses
            DispatchQueue.main.async {
            // Iterate over each line of data
            for line in lines {
                if let jsonLine = try? decoder.decode(Response.self, from: Data(line)) {
                    responses.append(jsonLine.response)  // Decode each line and append the response
                    self.model = jsonLine.model
                }
            }
         
                self.response = responses.joined(separator: "")  // Combine all responses into one string
               // print(self.response)  // Print the full response
            }
        }.resume()  // Resume the task if it was suspended
    }
    
}
