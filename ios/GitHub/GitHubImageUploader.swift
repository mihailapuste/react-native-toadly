import Foundation

class GitHubImageUploader {
    
    public static func uploadImage(
        imageData: Data,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        LoggingService.info("Uploading screenshot to GitHub")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "screenshot_\(timestamp).jpg"
        
        let base64Image = imageData.base64EncodedString()
        
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/contents/screenshots/\(filename)"
        
        guard let url = URL(string: urlString) else {
            LoggingService.error("Invalid URL for screenshot upload")
            completion(.failure(NSError(domain: "GitHubImageUploader", code: 10, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for screenshot upload"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let uploadData: [String: Any] = [
            "message": "Upload screenshot for bug report",
            "content": base64Image
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: uploadData, options: [])
        } catch {
            LoggingService.error("Failed to serialize screenshot upload data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                LoggingService.error("Network error during screenshot upload: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                LoggingService.error("Invalid response from screenshot upload")
                completion(.failure(NSError(domain: "GitHubImageUploader", code: 11, userInfo: [NSLocalizedDescriptionKey: "Invalid response from screenshot upload"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                var errorMessage = "GitHub API error during screenshot upload: \(httpResponse.statusCode)"
                
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    errorMessage += " - \(responseBody)"
                }
                
                LoggingService.error(errorMessage)
                completion(.failure(NSError(domain: "GitHubImageUploader", code: 12, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                LoggingService.error("No data received from screenshot upload")
                completion(.failure(NSError(domain: "GitHubImageUploader", code: 13, userInfo: [NSLocalizedDescriptionKey: "No data received from screenshot upload"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let content = json["content"] as? [String: Any],
                   let downloadUrl = content["download_url"] as? String {
                    LoggingService.info("Screenshot uploaded successfully: \(downloadUrl)")
                    completion(.success(downloadUrl))
                } else {
                    LoggingService.error("Could not parse screenshot upload response")
                    completion(.failure(NSError(domain: "GitHubImageUploader", code: 14, userInfo: [NSLocalizedDescriptionKey: "Could not parse screenshot upload response"])))
                }
            } catch {
                LoggingService.error("JSON parsing error for screenshot upload: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
