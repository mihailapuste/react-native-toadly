import Foundation

class GitHubIssueService {
    private static var githubToken: String?
    private static var repoOwner: String?
    private static var repoName: String?
    
    public static func setup(githubToken: String, repoOwner: String, repoName: String) {
        self.githubToken = githubToken
        self.repoOwner = repoOwner
        self.repoName = repoName
    }
    
    public static func submitIssue(email: String, title: String, details: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = githubToken, let owner = repoOwner, let repo = repoName else {
            completion(.failure(NSError(domain: "GitHubIssueService", code: 1, userInfo: [NSLocalizedDescriptionKey: "GitHub configuration not set. Call setup first."])))
            return
        }
        
        let issueBody = """
        **Reporter Email:** \(email)
        
        **Details:**
        \(details)
        """
        
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/issues"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GitHubIssueService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let issueData: [String: Any] = [
            "title": title,
            "body": issueBody
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: issueData, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "GitHubIssueService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                var errorMessage = "GitHub API error: \(httpResponse.statusCode)"
                
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    errorMessage += " - \(responseBody)"
                }

                completion(.failure(NSError(domain: "GitHubIssueService", code: 5, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "GitHubIssueService", code: 6, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let htmlUrl = json["html_url"] as? String {
                    completion(.success(htmlUrl))
                } else {
                    completion(.failure(NSError(domain: "GitHubIssueService", code: 7, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
