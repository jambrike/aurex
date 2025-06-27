import Foundation

class OpenRouterService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://openrouter.ai/api/v1"
    
    @Published var isLoading = false
    @Published var lastResponse: String = ""
    @Published var lastError: String = ""
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendMessage(_ message: String) async -> String? {
        await MainActor.run {
            isLoading = true
            lastError = ""
        }
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            await MainActor.run {
                isLoading = false
                lastError = "Invalid URL"
            }
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("aurex-ios-app", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("aurex-ios-app", forHTTPHeaderField: "X-Title")
        
        let requestBody: [String: Any] = [
            "model": "openai/gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Failed to serialize request body: \(error)")
            await MainActor.run {
                isLoading = false
                lastError = "Failed to prepare request"
            }
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    isLoading = false
                    lastError = "Invalid response"
                }
                return nil
            }
            
            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
                print("OpenRouter error: \(errorMessage)")
                await MainActor.run {
                    isLoading = false
                    lastError = "API Error: \(httpResponse.statusCode)"
                }
                return nil
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("OpenRouter response: \(responseString)")
            
            // Parse the response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                await MainActor.run {
                    self.lastResponse = content
                    self.isLoading = false
                }
                return content
            }
            
            await MainActor.run {
                isLoading = false
                lastError = "Failed to parse response"
            }
            return nil
            
        } catch {
            print("Network request failed: \(error)")
            await MainActor.run {
                isLoading = false
                lastError = "Network error: \(error.localizedDescription)"
            }
            return nil
        }
    }
} 