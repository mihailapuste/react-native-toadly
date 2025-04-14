import Foundation

public class GitHubService {
    private static var githubToken: String?
    private static var repoOwner: String?
    private static var repoName: String?
    
    public static func setup(githubToken: String, repoOwner: String, repoName: String) {
        self.githubToken = githubToken
        self.repoOwner = repoOwner
        self.repoName = repoName
        
        LoggingService.info("GitHubService setup completed")
    }
    
    public static func isSetup() -> Bool {
        return githubToken != nil && repoOwner != nil && repoName != nil
    }
    
    public static func submitIssue(
        email: String,
        title: String,
        details: String,
        jsLogs: String,
        screenshotData: Data? = nil,
        crashInfo: [String: Any]? = nil,
        reportType: String? = nil,
        sessionReplayData: Data? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let token = githubToken, let owner = repoOwner, let repo = repoName else {
            LoggingService.error("GitHub configuration not set. Call setup first.")
            completion(.failure(NSError(domain: "GitHubService", code: 1, userInfo: [NSLocalizedDescriptionKey: "GitHub configuration not set. Call setup first."])))
            return
        }
        
        // Upload screenshot if available
        var screenshotUrl: String? = nil
        var replayUrl: String? = nil
        let group = DispatchGroup()
        
        if let screenshotData = screenshotData {
            group.enter()
            uploadImage(
                data: screenshotData,
                filename: "screenshot.png",
                contentType: "image/png",
                token: token,
                owner: owner,
                repo: repo
            ) { result in
                switch result {
                case .success(let url):
                    screenshotUrl = url
                case .failure(let error):
                    LoggingService.error("Failed to upload screenshot: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // Upload session replay if available
        if let sessionReplayData = sessionReplayData {
            group.enter()
            uploadImage(
                data: sessionReplayData,
                filename: "session_replay.gif",
                contentType: "image/gif",
                token: token,
                owner: owner,
                repo: repo
            ) { result in
                switch result {
                case .success(let url):
                    replayUrl = url
                    LoggingService.info("Session replay GIF uploaded successfully")
                case .failure(let error):
                    LoggingService.error("Failed to upload session replay: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Create the issue with the screenshot URL if available
            GitHubIssueCreator.createIssue(
                email: email,
                title: title,
                details: details,
                jsLogs: jsLogs,
                screenshotUrl: screenshotUrl,
                replayUrl: replayUrl,
                crashInfo: crashInfo,
                reportType: reportType,
                token: token,
                owner: owner,
                repo: repo,
                completion: completion
            )
        }
    }
    
    private static func uploadImage(
        data: Data,
        filename: String,
        contentType: String,
        token: String,
        owner: String,
        repo: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        GitHubImageUploader.uploadImage(
            data: data,
            filename: filename,
            contentType: contentType,
            token: token,
            owner: owner,
            repo: repo,
            completion: completion
        )
    }
}
