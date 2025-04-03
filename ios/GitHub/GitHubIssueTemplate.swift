import Foundation

public struct GitHubIssueTemplate {
    public static func generateIssueBody(
        email: String,
        details: String,
        jsLogs: String,
        nativeLogs: String,
        screenshotUrl: String? = nil
    ) -> String {
        var issueBody = """
        ### Description
        \(details)
        
        | Properties | |
        | ----- | ----- |
        | Email | \(email) |
        
        ### Logs
        
        #### JavaScript Logs
        ```
        \(jsLogs)
        ```
        
        #### Native Logs
        ```
        \(nativeLogs)
        ```
        
        """
        
        if let screenshotUrl = screenshotUrl, !screenshotUrl.isEmpty {
            issueBody += """
            ### Screenshot
            <details open>
              <summary>Screenshot</summary>
              <img src="\(screenshotUrl)" alt="Screenshot" height="500">
            </details>
            """
        }
        
        return issueBody
    }
}
