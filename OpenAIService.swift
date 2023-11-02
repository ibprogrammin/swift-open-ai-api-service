//
//  OpenAIRequest.swift
//
//  Created by Daniel Sevitti on 2023-11-01.
//
//  Connect to OpenAI API web service

import Foundation

var openAIPrompt : String = "Input your prompt here"
var openAIResponse : String = ""

var defaultOpenAIModel : String = "gpt-3.5.turbo"
var defaultTokens : Int = 50

// Perform a request to the OpenAI rest API
func makeOpenAiRequest(completion: @escaping (String?) -> Void) {
    // Define the endpoint URL for the OpenAI API
    let apiEndpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    // Define your OpenAI API key
    let apiKey: String = "Insert your API Key here!"

    // Create a dictionary with your message
    let messageData: [String: Any] = [
        "role": "user",
        "content": "\(openAIPrompt)"
    ]

    // Initialize the OpenAI request data
    let requestData: [String: Any] = [
        "model": defaultOpenAIModel,
        "messages": [messageData],
        "max_tokens": defaultTokens
    ]
    
    // Convert the message data to JSON
    let jsonData: Data
    do {
        jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])
    } catch {
        print("Error converting message data to JSON: \(error)")
        exit(1)
    }
    
    print(String(data: jsonData, encoding: .utf8) ?? "Error in jsonData")

    // Create a URL request
    var request = URLRequest(url: apiEndpoint)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    print("Starting openAi request")
    // Perform the API request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        guard let data = data else {
            print("Error: No data received")
            return
        }
        
        do {
            print(String(decoding: data, as: UTF8.self))
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                    DispatchQueue.global(qos: .userInitiated).sync {
                        print("Received response: \(content)")
                        // update our calling method with the returned content
                        completion(content)
                    }
            } else {
                print("Error parsing data!")
            }
            
        } catch let jsonerror as NSError {
            print("Error parsing JSON response: \(jsonerror)")
        }
    }
        
    task.resume()
    
    print("OpenAI request complete!")
}
