import UIKit
import NitroModules

class Toadly: HybridToadlySpec {
    private let bugReportDialog = BugReportDialog()
    private var jsLogs: String = ""
    
    public func setup(githubToken: String, repoOwner: String, repoName: String) throws {
        LoggingService.info("Setting up Toadly with GitHub integration")
        GitHubIssueService.setup(githubToken: githubToken, repoOwner: repoOwner, repoName: repoName)
    }
    
    public func addJSLogs(logs: String) throws {
        self.jsLogs = logs
        LoggingService.info("Received JavaScript logs")
    }

    public func show() throws {
        LoggingService.info("Showing bug report dialog")
        guard let rootViewController = BugReportDialog.getRootViewController() else {
            LoggingService.error("Failed to get root view controller")
            return
        }

        bugReportDialog.show(
            from: rootViewController,
            onSubmit: { email, title, details in
                LoggingService.info("Bug report submitted with title: \(title)")
                GitHubIssueService.submitIssue(email: email, title: title, details: details, jsLogs: self.jsLogs) { result in
                    switch result {
                    case .success(let issueUrl):
                        LoggingService.info("Bug Report Submitted to GitHub: \(issueUrl)")
                        print("Bug Report Submitted to GitHub: \(issueUrl)")
                    case .failure(let error):
                        LoggingService.error("Failed to submit bug report to GitHub: \(error.localizedDescription)")
                        print("Failed to submit bug report to GitHub: \(error.localizedDescription)")
                    }
                }
            },
            onCancel: {
                LoggingService.info("Bug report cancelled")
                print("Bug report cancelled")
            }
        )
    }
}
