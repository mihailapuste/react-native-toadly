/**
 * Interface for ErrorHandlingService
 * This helps avoid circular dependencies between services
 */
export interface IErrorHandlingService {
  captureJSCrash(error: Error, isFatal?: boolean): void;
  submitErrorAsGitHubIssue(error: Error, isFatal?: boolean): void;
  enableAutomaticCrashReporting(enable?: boolean): void;
  enableAutomaticIssueSubmission(enable?: boolean): void;
  isAutomaticIssueSubmissionEnabled(): boolean;
}

/**
 * Interface for LoggingService
 * This helps avoid circular dependencies between services
 */
export interface ILoggingService {
  getRecentLogs(): string;
  addLog(message: string): void;
  clearLogs(): void;
  logError(error: Error, fatal?: boolean): void;
}
