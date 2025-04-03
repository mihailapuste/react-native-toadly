import UIKit
import NitroModules

class Toadly: HybridToadlySpec {
    private let bugReportDialog = BugReportDialog()
    private var jsLogs: String = ""
    private var screenshotData: Data?
    
    public func setup(githubToken: String, repoOwner: String, repoName: String) throws {
        LoggingService.info("Setting up Toadly with GitHub integration")
        GitHubService.setup(githubToken: githubToken, repoOwner: repoOwner, repoName: repoName)
    }
    
    public func addJSLogs(logs: String) throws {
        self.jsLogs = logs
        LoggingService.info("Received JavaScript logs")
    }
    
    private func captureScreenshot() {
        LoggingService.info("Capturing screenshot")
        
        // Use a safer approach to capture screenshots
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first else {
                LoggingService.error("Failed to find key window for screenshot")
                return
            }
            
            // Create a safer context for capturing screenshots
            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            format.opaque = false
            
            // Use try-catch to handle potential errors
            do {
                let renderer = UIGraphicsImageRenderer(bounds: keyWindow.bounds, format: format)
                
                let screenshot = renderer.image { context in
                    // Safely capture the window contents
                    keyWindow.layer.render(in: context.cgContext)
                }
                
                // Convert the image to JPEG data
                if let imageData = screenshot.jpegData(compressionQuality: 0.8) {
                    self.screenshotData = imageData
                    LoggingService.info("Screenshot captured successfully")
                } else {
                    LoggingService.error("Failed to convert screenshot to JPEG data")
                }
            } catch {
                LoggingService.error("Error capturing screenshot: \(error.localizedDescription)")
                // Continue without a screenshot
            }
        }
    }

    public func show() throws {
        LoggingService.info("Showing bug report dialog")
        
        // Capture screenshot first, then show dialog after a short delay to ensure completion
        captureScreenshot()
        
        // Wait a short moment to ensure screenshot capture completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            guard let rootViewController = BugReportDialog.getRootViewController() else {
                LoggingService.error("Failed to get root view controller")
                return
            }

            self.bugReportDialog.show(
                from: rootViewController,
                onSubmit: { [weak self] email, title, details in
                    guard let self = self else { return }
                    
                    LoggingService.info("Bug report submitted with title: \(title)")
                    
                    GitHubService.submitIssue(
                        email: email,
                        title: title,
                        details: details,
                        jsLogs: self.jsLogs,
                        screenshotData: self.screenshotData
                    ) { result in
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
}
