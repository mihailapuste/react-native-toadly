import Foundation
import UIKit

public struct GitHubIssueTemplate {
    public static func generateIssueBody(
        email: String,
        details: String,
        jsLogs: String,
        nativeLogs: String,
        screenshotUrl: String? = nil,
        replayUrl: String? = nil,
        crashInfo: [String: Any]? = nil,
        reportType: String? = nil
    ) -> String {
        // Get device and app information
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let deviceName = UIDevice.current.name
        let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        let timestamp = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let dateString = dateFormatter.string(from: timestamp)
        
        // Get memory information
        let memoryFormatter = ByteCountFormatter()
        memoryFormatter.allowedUnits = [.useGB, .useMB]
        memoryFormatter.countStyle = .memory
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let formattedMemory = memoryFormatter.string(fromByteCount: Int64(totalMemory))
        
        // Get screen information
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenScale = UIScreen.main.scale
        
        // Get locale information
        let locale = Locale.current
        let language = locale.languageCode ?? "Unknown"
        let region = locale.regionCode ?? "Unknown"
        
        // Get network information
        let isWiFiEnabled = ProcessInfo.processInfo.environment["SIMULATOR_CAPABILITIES"] == nil ? "Unknown" : "Yes (Simulator)"
        
        // Get battery information
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel < 0 ? "Unknown" : "\(Int(UIDevice.current.batteryLevel * 100))%"
        let batteryState: String
        switch UIDevice.current.batteryState {
        case .unknown:
            batteryState = "Unknown"
        case .unplugged:
            batteryState = "Unplugged"
        case .charging:
            batteryState = "Charging"
        case .full:
            batteryState = "Full"
        @unknown default:
            batteryState = "Unknown"
        }
        
        // Get disk space information
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let attributes = try? fileManager.attributesOfFileSystem(forPath: documentsDirectory.path)
        let freeSpace = attributes?[.systemFreeSize] as? NSNumber
        let totalSpace = attributes?[.systemSize] as? NSNumber
        let freeSpaceString = freeSpace != nil ? memoryFormatter.string(fromByteCount: freeSpace!.int64Value) : "Unknown"
        let totalSpaceString = totalSpace != nil ? memoryFormatter.string(fromByteCount: totalSpace!.int64Value) : "Unknown"
        
        // Get report type information
        let reportTypeText = reportType ?? "Bug"
        let reportTypeIcon = getIconForReportType(reportType)
        
        var issueBody = """
        ### Description
        \(details)
        
        ### Report Information
        | Property | Value |
        | ----- | ----- |
        | Report Type | \(reportTypeIcon) \(reportTypeText) |
        | Email | \(email) |
        | Timestamp | \(dateString) |
        
        ### Device & App Information
        | Property | Value |
        | ----- | ----- |
        | App Version | \(appVersion) (\(buildNumber)) |
        | Device Model | \(deviceModel) |
        | Device Name | \(deviceName) |
        | OS | \(systemName) \(systemVersion) |
        | Device ID | \(deviceIdentifier) |
        | Memory | \(formattedMemory) |
        | Free Disk Space | \(freeSpaceString) / \(totalSpaceString) |
        | Screen | \(screenWidth)x\(screenHeight) @\(screenScale)x |
        | Language | \(language)_\(region) |
        | Battery | \(batteryLevel) (\(batteryState)) |
        | WiFi | \(isWiFiEnabled) |
        """
        
        // Add crash-specific information if available
        if let crashInfo = crashInfo {
            let crashType = crashInfo["crashType"] as? String ?? "Unknown"
            let crashTimestamp = crashInfo["timestamp"] as? TimeInterval
            
            var crashDateString = "Unknown"
            if let crashTimestamp = crashTimestamp {
                let crashDate = Date(timeIntervalSince1970: crashTimestamp)
                crashDateString = dateFormatter.string(from: crashDate)
            }
            
            issueBody += """
            
            ### Crash Information
            | Property | Value |
            | ----- | ----- |
            | Crash Type | \(crashType) |
            | Crash Time | \(crashDateString) |
            """
        }
        
        issueBody += """
        
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
        
        // Add session replay if available
        if let replayUrl = replayUrl {
            issueBody += """
            
            <details>
            <summary>📽️ Session Replay (Last 15 seconds)</summary>
            
            ![Session Replay](\(replayUrl))
            </details>
            """
        }
        
        // Add screenshot if available
        if let screenshotUrl = screenshotUrl {
            issueBody += """
            
            <details>
            <summary>📷 Screenshot</summary>
            
            ![Screenshot](\(screenshotUrl))
            </details>
            """
        }
        
        return issueBody
    }
    
    private static func getIconForReportType(_ reportType: String?) -> String {
        guard let reportType = reportType else { return "🐛" }
        
        switch reportType.lowercased() {
        case "bug":
            return "🐛"
        case "suggestion":
            return "💡"
        case "crash":
            return "🚨"
        case "question":
            return "❓"
        default:
            return "🐛"
        }
    }
}
