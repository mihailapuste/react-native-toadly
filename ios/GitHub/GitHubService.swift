import Foundation

class GitHubService {
    private static var githubToken: String?
    private static var repoOwner: String?
    private static var repoName: String?
    
    public static func setup(githubToken: String, repoOwner: String, repoName: String) {
        self.githubToken = githubToken
        self.repoOwner = repoOwner
        self.repoName = repoName
        
        LoggingService.info("GitHubService setup completed")
    }
    
    public static func submitIssue(
        email: String,
        title: String,
        details: String,
        jsLogs: String,
        screenshotData: Data? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let token = githubToken, let owner = repoOwner, let repo = repoName else {
            LoggingService.error("GitHub configuration not set. Call setup first.")
            completion(.failure(NSError(domain: "GitHubService", code: 1, userInfo: [NSLocalizedDescriptionKey: "GitHub configuration not set. Call setup first."])))
            return
        }

       guard let imageData = screenshotData else {
            GitHubIssueCreator.createIssueWithoutScreenshot(
                email: email,
                title: title,
                details: details,
                jsLogs: jsLogs,
                token: token,
                owner: owner,
                repo: repo,
                completion: completion
            )
            return
        }
        
        GitHubImageUploader.uploadImage(
            imageData: imageData,
                token: token,
                owner: owner,
                repo: repo
            ) { result in
                switch result {
                case .success(let imageUrl):
                    GitHubIssueCreator.createIssueWithScreenshot(
                        email: email,
                        title: title,
                        details: details,
                        jsLogs: jsLogs,
                        screenshotUrl: imageUrl,
                        token: token,
                        owner: owner,
                        repo: repo,
                        completion: completion
                    )
                case .failure(let error):
                    // Continue with issue creation without the screenshot
                    LoggingService.error("Failed to upload screenshot: \(error.localizedDescription)")

                    GitHubIssueCreator.createIssueWithoutScreenshot(
                        email: email,
                        title: title,
                        details: details,
                        jsLogs: jsLogs,
                        token: token,
                        owner: owner,
                        repo: repo,
                        completion: completion
                    )
                }
            }
    }
}
