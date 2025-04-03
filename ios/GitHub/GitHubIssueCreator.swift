import Foundation

class GitHubIssueCreator {
    public static func createIssueWithScreenshot(
        email: String,
        title: String,
        details: String,
        jsLogs: String,
        screenshotUrl: String,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let nativeLogs = LoggingService.getRecentLogs()
        
        let issueBody = """
        **Reporter Email:** \(email)
        
        **Details:**
        \(details)
        
        **Screenshot:**
        ![Screenshot](\(screenshotUrl))
        
        ---
        
        ### JavaScript Logs
        ```
        \(jsLogs)
        ```
        
        ### Native Logs
        ```
        \(nativeLogs)
        ```
        """
        
        createIssue(
            title: title,
            body: issueBody,
            token: token,
            owner: owner,
            repo: repo,
            completion: completion
        )
    }
    
    public static func createIssueWithoutScreenshot(
        email: String,
        title: String,
        details: String,
        jsLogs: String,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let nativeLogs = LoggingService.getRecentLogs()
        
        let issueBody = """
        **Reporter Email:** \(email)
        
        **Details:**
        \(details)
        
        ---
        
        ### JavaScript Logs
        ```
        \(jsLogs)
        ```
        
        ### Native Logs
        ```
        \(nativeLogs)
        ```
        """
        
        createIssue(
            title: title,
            body: issueBody,
            token: token,
            owner: owner,
            repo: repo,
            completion: completion
        )
    }
    
    private static func createIssue(
        title: String,
        body: String,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/issues"
        guard let url = URL(string: urlString) else {
            LoggingService.error("Invalid URL")
            completion(.failure(NSError(domain: "GitHubIssueCreator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let issueData: [String: Any] = [
            "title": title,
            "body": body
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: issueData, options: [])
        } catch {
            LoggingService.error("Failed to serialize issue data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        LoggingService.info("Submitting issue to GitHub: \(title)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                LoggingService.error("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                LoggingService.error("Invalid response")
                completion(.failure(NSError(domain: "GitHubIssueCreator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                var errorMessage = "GitHub API error: \(httpResponse.statusCode)"
                
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    errorMessage += " - \(responseBody)"
                }
                
                LoggingService.error(errorMessage)
                completion(.failure(NSError(domain: "GitHubIssueCreator", code: 5, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                LoggingService.error("No data received")
                completion(.failure(NSError(domain: "GitHubIssueCreator", code: 6, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let htmlUrl = json["html_url"] as? String {
                    LoggingService.info("Issue created successfully: \(htmlUrl)")
                    completion(.success(htmlUrl))
                } else {
                    LoggingService.error("Could not parse response")
                    completion(.failure(NSError(domain: "GitHubIssueCreator", code: 7, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])))
                }
            } catch {
                LoggingService.error("JSON parsing error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
