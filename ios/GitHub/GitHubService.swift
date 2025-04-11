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
        crashInfo: [String: Any]? = nil,
        reportType: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let token = githubToken, let owner = repoOwner, let repo = repoName else {
            LoggingService.error("GitHub configuration not set. Call setup first.")
            completion(.failure(NSError(domain: "GitHubService", code: 1, userInfo: [NSLocalizedDescriptionKey: "GitHub configuration not set. Call setup first."])))
            return
        }

        if screenshotData == nil {
            createGitHubIssue(
                email: email, 
                title: title, 
                details: details, 
                jsLogs: jsLogs, 
                screenshotUrl: nil, 
                crashInfo: crashInfo,
                reportType: reportType,
                token: token, 
                owner: owner, 
                repo: repo, 
                completion: completion
            )
            return
        }
        
        GitHubImageUploader.uploadImage(
            imageData: screenshotData!,
            token: token,
            owner: owner,
            repo: repo
        ) { result in
            var screenshotUrl: String? = nil
            
            switch result {
            case .success(let imageUrl):
                screenshotUrl = imageUrl
            case .failure(let error):
                LoggingService.error("Failed to upload screenshot: \(error.localizedDescription)")
            }
            
            self.createGitHubIssue(
                email: email,
                title: title,
                details: details,
                jsLogs: jsLogs,
                screenshotUrl: screenshotUrl,
                crashInfo: crashInfo,
                reportType: reportType,
                token: token,
                owner: owner,
                repo: repo,
                completion: completion
            )
        }
    }
    
    private static func createGitHubIssue(
        email: String,
        title: String,
        details: String,
        jsLogs: String,
        screenshotUrl: String?,
        crashInfo: [String: Any]? = nil,
        reportType: String? = nil,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        GitHubIssueCreator.createIssue(
            email: email,
            title: title,
            details: details,
            jsLogs: jsLogs,
            screenshotUrl: screenshotUrl,
            crashInfo: crashInfo,
            reportType: reportType,
            token: token,
            owner: owner,
            repo: repo,
            completion: completion
        )
    }
}
