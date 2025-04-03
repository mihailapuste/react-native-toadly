import Foundation

class LoggingService {
    private static var logs: [String] = []
    private static let maxLogs = 50
    
    public static func log(_ message: String, level: String = "INFO") {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = "[\(timestamp)] [\(level)] \(message)"
        
        // Add to logs array, maintaining max size
        logs.append(logEntry)
        if logs.count > maxLogs {
            logs.removeFirst()
        }
        
        print(logEntry)
    }
    
    public static func getRecentLogs() -> String {
        return logs.joined(separator: "\n")
    }
    
    public static func clearLogs() {
        logs.removeAll()
    }
    
    public static func info(_ message: String) {
        log(message, level: "INFO")
    }
    
    public static func warn(_ message: String) {
        log(message, level: "WARN")
    }
    
    public static func error(_ message: String) {
        log(message, level: "ERROR")
    }
}
