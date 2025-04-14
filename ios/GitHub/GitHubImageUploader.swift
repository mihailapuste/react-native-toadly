import Foundation

class GitHubImageUploader {
    public static func uploadImage(
        data: Data,
        filename: String = "screenshot.png",
        contentType: String = "image/png",
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // First check if the file exists
        checkFileExists(
            filename: filename,
            token: token,
            owner: owner,
            repo: repo
        ) { result in
            // GitHub's raw content URL format
            let imageUrl = "https://github.com/\(owner)/\(repo)/blob/main/\(filename)?raw=true"
            
            switch result {
            case .success(let existingSha):
                // File exists, update it
                self.updateFile(
                    data: data,
                    filename: filename,
                    existingSha: existingSha,
                    token: token,
                    owner: owner,
                    repo: repo
                ) { result in
                    switch result {
                    case .success:
                        completion(.success(imageUrl))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                // If the error is that the file doesn't exist, create it
                if (error as NSError).domain == "GitHubImageUploader" && (error as NSError).code == 404 {
                    self.createFile(
                        data: data,
                        filename: filename,
                        token: token,
                        owner: owner,
                        repo: repo
                    ) { result in
                        switch result {
                        case .success:
                            completion(.success(imageUrl))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private static func checkFileExists(
        filename: String,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/contents/\(filename)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GitHubImageUploader", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    // File doesn't exist
                    completion(.failure(NSError(domain: "GitHubImageUploader", code: 404, userInfo: [NSLocalizedDescriptionKey: "File does not exist"])))
                    return
                } else if (200...299).contains(httpResponse.statusCode) {
                    // File exists, get its SHA
                    guard let data = data else {
                        completion(.failure(NSError(domain: "GitHubImageUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let sha = json["sha"] as? String {
                            completion(.success(sha))
                        } else {
                            completion(.failure(NSError(domain: "GitHubImageUploader", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        completion(.failure(NSError(domain: "GitHubImageUploader", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to check file existence: \(responseString)"])))
                    } else {
                        completion(.failure(NSError(domain: "GitHubImageUploader", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to check file existence"])))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "GitHubImageUploader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }
        }
        
        task.resume()
    }
    
    private static func createFile(
        data: Data,
        filename: String,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/contents/\(filename)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GitHubImageUploader", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        // Base64 encode the image data
        let base64Content = data.base64EncodedString()
        
        let content: [String: Any] = [
            "message": "Upload \(filename) for issue",
            "content": base64Content
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: content, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check if the response is successful (status code 2xx)
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    completion(.failure(NSError(domain: "GitHubImageUploader", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create file: \(responseString)"])))
                } else {
                    completion(.failure(NSError(domain: "GitHubImageUploader", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create file"])))
                }
            }
        }
        
        task.resume()
    }
    
    private static func updateFile(
        data: Data,
        filename: String,
        existingSha: String,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/contents/\(filename)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GitHubImageUploader", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        // Base64 encode the image data
        let base64Content = data.base64EncodedString()
        
        let content: [String: Any] = [
            "message": "Update \(filename) for issue",
            "content": base64Content,
            "sha": existingSha
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: content, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check if the response is successful (status code 2xx)
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    completion(.failure(NSError(domain: "GitHubImageUploader", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to update file: \(responseString)"])))
                } else {
                    completion(.failure(NSError(domain: "GitHubImageUploader", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to update file"])))
                }
            }
        }
        
        task.resume()
    }
}
