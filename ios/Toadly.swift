import UIKit
import NitroModules

class Toadly: HybridToadlySpec {
    private let bugReportDialog = BugReportDialog()
    
    public func setup(githubToken: String, repoOwner: String, repoName: String) throws {
        GitHubIssueService.setup(githubToken: githubToken, repoOwner: repoOwner, repoName: repoName)
    }

    public func show() throws {
        guard let rootViewController = BugReportDialog.getRootViewController() else {
            return
        }

        bugReportDialog.show(
            from: rootViewController,
            onSubmit: { email, title, details in
                GitHubIssueService.submitIssue(email: email, title: title, details: details) { result in
                    switch result {
                    case .success(let issueUrl):
                        print("Bug Report Submitted to GitHub: \(issueUrl)")
                    case .failure(let error):
                        print("Failed to submit bug report to GitHub: \(error.localizedDescription)")
                    }
                }
            },
            onCancel: {
                print("Bug report cancelled")
            }
        )
    }
}
