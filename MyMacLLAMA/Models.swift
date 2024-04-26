//
//  Models.swift
//  MyMacLLAMA
//
//  Created by Carlos Mbendera on 25/04/2024.
//

import Foundation

class DataInterface: ObservableObject, Observable {
    
    @Published var prompt: String = ""
    @Published var response: String = ""
    @Published var isSending: Bool = false

    func sendPrompt() {
        print("Started Send Prompt")
        guard !prompt.isEmpty, !isSending else { return }
        isSending = true
        
        let urlString = "http://127.0.0.1:11434/api/generate"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "llama3",
            "prompt": prompt,
            "options": [
                "num_ctx": 4096
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { self.isSending = false } }
            if let error = error {
                DispatchQueue.main.async { self.response = "Error: \(error.localizedDescription)" }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { self.response = "No data received" }
                return
            }
            
            let decoder = JSONDecoder()
            let lines = data.split(separator: 10)
            var responses = [String]()
            
            
            for line in lines {
                if let jsonLine = try? decoder.decode(Response.self, from: Data(line)) {
                    responses.append(jsonLine.response)
                    
                }
            }
            
            print(responses)
            
            DispatchQueue.main.async {
                self.response = responses.joined(separator: "")
                print(self.response) // Print full response
            }
        }.resume()
    }
}

struct Response: Codable {
    let model: String
    let response: String
}
