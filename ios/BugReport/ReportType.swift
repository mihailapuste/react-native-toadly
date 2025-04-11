import Foundation

public enum BugReportType: String, CaseIterable {
    case bug = "Bug"
    case suggestion = "Suggestion"
    case question = "Question"
    case crash = "Crash"
    
    public var icon: String {
        switch self {
        case .bug:
            return "🐞"
        case .suggestion:
            return "💡"
        case .crash:
            return "🚨"
        case .question:
            return "❓"
        }
    }
    
    public var displayText: String {
        return "\(icon) \(rawValue)"
    }
}
