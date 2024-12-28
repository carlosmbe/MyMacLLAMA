//
//  Helpers.swift
//  MyMacLLAMA
//
//  Created by Carlos Mbendera on 27/12/2024.
//


///Special Shout Out to @Zach Waugh's article on streaming LLM Responses to SwiftUI Text
///https://zachwaugh.com/posts/streaming-messages-chatgpt-swift-asyncsequence

import Foundation

///Get Models Helpers
    // Root object returned by the API
    struct LocalModelsResponse: Decodable {
        let models: [LocalModel]
    }

    // Represents each model item 
    struct LocalModel: Decodable, Identifiable, Hashable {
        var id: String { name }
        
        let name: String
        let modified_at: String
        let size: Int
        let digest: String
        let details: ModelDetails
    }

    struct ModelDetails: Decodable, Hashable {
        let format: String
        let family: String
        let families: [String]?
        let parameter_size: String
        let quantization_level: String
    }


///Streaming Reponse Helpers
extension DataInterface {
    struct Chunk: Decodable {
        let model: String?
        let created_at: String?
        let response: String?
        let done: Bool?
        let done_reason: String?
        let context: [Int]?
        let total_duration: Int?
        let load_duration: Int?
        let prompt_eval_count: Int?
        let prompt_eval_duration: Int?
        let eval_count: Int?
        let eval_duration: Int?
    }

    /// Attempts to parse a single line of text into a `Chunk`.
    /// - Returns: The `response` string if the chunk is not done,
    ///            `"\n"` if done is `true`,
    ///            or `nil` if the line isn't valid JSON or doesn't parse correctly.
    func parse(_ line: String) -> String? {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Skip non-JSON lines (e.g., "Publishing changes..." logs)
        guard trimmedLine.first == "{" else {
            return nil
        }
        
        guard let data = trimmedLine.data(using: .utf8) else {
            return nil
        }
        
        do {
            let chunk = try JSONDecoder().decode(Chunk.self, from: data)
            
            // If done is true, return a new line to signal completion
            if chunk.done == true {
                return "\n"
            }
            
            // Otherwise, return the response text (or nil if it doesn't exist)
            return chunk.response
            
        } catch {
            // Failed to decode JSON ignore this line
            return nil
        }
    }

    
}
