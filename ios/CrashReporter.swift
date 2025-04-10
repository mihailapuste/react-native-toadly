import Foundation
import UIKit

// Define a global C function for exception handling
private func myUncaughtExceptionHandler(exception: NSException) {
    CrashReporter.handleException(exception)
}

// Define global C functions for signal handling
private func signalHandler(signal: Int32) {
    CrashReporter.handleSignal(signal)
}

class CrashReporter {
    private static var isSetup = false

    static func setup() {
        guard !isSetup else {
            LoggingService.info("Crash reporter already set up")
            return
        }
        
        isSetup = true
        LoggingService.info("Setting up native crash reporter")
        
        // Set up exception handler for uncaught exceptions
        NSSetUncaughtExceptionHandler(myUncaughtExceptionHandler)
        
        // Set up signal handlers for various crash signals
        signal(SIGABRT, signalHandler)
        signal(SIGILL, signalHandler)
        signal(SIGSEGV, signalHandler)
        signal(SIGFPE, signalHandler)
        signal(SIGBUS, signalHandler)
        signal(SIGPIPE, signalHandler)
        
        // Check for previous crash reports on app startup
        checkForPreviousCrashes()
    }
    
    // Handle signals that can cause crashes
    static func handleSignal(_ signal: Int32) {
        let signalName = signalToName(signal)
        LoggingService.error("App is crashing due to signal: \(signalName) (\(signal))")
        
        // Create a detailed crash log
        let crashLog = "Signal: \(signalName) (\(signal))\n" +
                      "Stack Trace: Not available for signals\n"
        
        // Try to report the crash immediately
        let crashType = "Signal: \(signalName)"
        reportCrashImmediately(crashType: crashType, details: crashLog)
    }
    
    // Convert signal numbers to readable names
    private static func signalToName(_ signal: Int32) -> String {
        switch signal {
        case SIGABRT: return "SIGABRT (Abort)"
        case SIGILL: return "SIGILL (Illegal Instruction)"
        case SIGSEGV: return "SIGSEGV (Segmentation Fault)"
        case SIGFPE: return "SIGFPE (Floating Point Exception)"
        case SIGBUS: return "SIGBUS (Bus Error)"
        case SIGPIPE: return "SIGPIPE (Broken Pipe)"
        default: return "Unknown Signal"
        }
    }
    
    // This method is called by the global exception handler
    static func handleException(_ exception: NSException) {
        LoggingService.error("App is crashing due to uncaught exception: \(exception.name.rawValue)")
        
        // Create a detailed crash log
        var crashLog = "Exception: \(exception.name.rawValue)\n"
        crashLog += "Reason: \(exception.reason ?? "No reason")\n"
        crashLog += "User Info: \(exception.userInfo ?? [:])\n"
        crashLog += "Stack Trace:\n\(exception.callStackSymbols.joined(separator: "\n"))"
        
        // Try to report the crash immediately
        let crashType = "Exception: \(exception.name.rawValue)"
        reportCrashImmediately(crashType: crashType, details: crashLog)
    }
    
    private static func getCrashReportPath() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("toadly_crash_report.json")
    }
    
    private static func reportCrashImmediately(crashType: String, details: String) {
        // Format crash report for GitHub issue
        let title = "Native Crash: \(crashType)"
        let formattedDetails = formatCrashDetails(crashType: crashType, details: details)
        
        // Create a semaphore to make the submission synchronous
        let semaphore = DispatchSemaphore(value: 0)
        var submissionSuccessful = false
        
        // Try to submit the crash report immediately
        GitHubService.submitIssue(
            email: "auto-generated@toadly.app",
            title: title,
            details: formattedDetails,
            jsLogs: "",
            screenshotData: nil
        ) { result in
            switch result {
            case .success(let issueUrl):
                LoggingService.info("Native Crash Report Submitted to GitHub: \(issueUrl)")
                print("Native Crash Report Submitted to GitHub: \(issueUrl)")
                submissionSuccessful = true
            case .failure(let error):
                LoggingService.error("Failed to submit native crash report to GitHub: \(error.localizedDescription)")
                print("Failed to submit native crash report to GitHub: \(error.localizedDescription)")
            }
            semaphore.signal()
        }
        
        // Wait for a short time to allow the submission to complete
        // Use a timeout to ensure we don't block the crash handling for too long
        let waitResult = semaphore.wait(timeout: .now() + 3.0) // 3 second timeout
        
        // If submission failed or timed out, save the crash report for later
        if waitResult == .timedOut || !submissionSuccessful {
            LoggingService.info("Crash report submission timed out or failed, saving for later")
            saveCrashReport(crashType: crashType, details: details)
        }
    }
    
    static func saveCrashReport(crashType: String, details: String? = nil) {
        let crashInfo: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "crashType": crashType,
            "details": details ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "buildNumber": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            "deviceModel": UIDevice.current.model,
            "systemVersion": UIDevice.current.systemVersion
        ]
        
        if let crashData = try? JSONSerialization.data(withJSONObject: crashInfo) {
            let crashReportPath = getCrashReportPath()
            try? crashData.write(to: crashReportPath)
            LoggingService.info("Saved crash report to: \(crashReportPath.path)")
        }
    }
    
    private static func checkForPreviousCrashes() {
        let crashReportPath = getCrashReportPath()
        
        guard FileManager.default.fileExists(atPath: crashReportPath.path),
              let crashData = try? Data(contentsOf: crashReportPath),
              let crashInfo = try? JSONSerialization.jsonObject(with: crashData) as? [String: Any] else {
            return
        }
        
        LoggingService.info("Found previous crash report, submitting to GitHub")
        
        let crashType = crashInfo["crashType"] as? String ?? "Unknown Crash"
        let crashDetails = crashInfo["details"] as? String ?? ""
        
        // Submit the crash report to GitHub.
        let title = "Native Crash: \(crashType)"
        let formattedDetails = formatCrashDetails(crashType: crashType, details: crashDetails, 
                                                 timestamp: crashInfo["timestamp"] as? TimeInterval,
                                                 appVersion: crashInfo["appVersion"] as? String,
                                                 buildNumber: crashInfo["buildNumber"] as? String,
                                                 deviceModel: crashInfo["deviceModel"] as? String,
                                                 systemVersion: crashInfo["systemVersion"] as? String)
        
        submitCrashReport(title: title, details: formattedDetails)
        
        // Delete the crash report file after submission.
        try? FileManager.default.removeItem(at: crashReportPath)
    }
    
    private static func formatCrashDetails(crashType: String, details: String, 
                                          timestamp: TimeInterval? = nil,
                                          appVersion: String? = nil,
                                          buildNumber: String? = nil,
                                          deviceModel: String? = nil,
                                          systemVersion: String? = nil) -> String {
        // Use provided values or get current values
        let currentTimestamp = timestamp ?? Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: currentTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let dateString = dateFormatter.string(from: date)
        
        let currentAppVersion = appVersion ?? (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
        let currentBuildNumber = buildNumber ?? (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
        let currentDeviceModel = deviceModel ?? UIDevice.current.model
        let currentSystemVersion = systemVersion ?? UIDevice.current.systemVersion
        
        return """
        ## Native iOS Crash Report
        
        ### Crash Information
        - **Type**: \(crashType)
        - **Time**: \(dateString)
        
        ### App Information
        - **Version**: \(currentAppVersion) (\(currentBuildNumber))
        - **Device**: \(currentDeviceModel)
        - **iOS Version**: \(currentSystemVersion)
        
        ### Crash Details
        ```
        \(details)
        ```
        
        This crash report was automatically generated by Toadly.
        """
    }
    
    private static func submitCrashReport(title: String, details: String) {
        GitHubService.submitIssue(
            email: "auto-generated@toadly.app",
            title: title,
            details: details,
            jsLogs: "",
            screenshotData: nil,
            crashInfo: [
                "crashType": title.replacingOccurrences(of: "Native Crash: ", with: ""),
                "timestamp": Date().timeIntervalSince1970,
                "details": details
            ]
        ) { result in
            switch result {
            case .success(let issueUrl):
                LoggingService.info("Native Crash Report Submitted to GitHub: \(issueUrl)")
                print("Native Crash Report Submitted to GitHub: \(issueUrl)")
            case .failure(let error):
                LoggingService.error("Failed to submit native crash report to GitHub: \(error.localizedDescription)")
                print("Failed to submit native crash report to GitHub: \(error.localizedDescription)")
            }
        }
    }
}