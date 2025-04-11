export interface IErrorHandlingService {
  captureJSCrash(error: Error, isFatal?: boolean): void;
  createIssue(error: Error, isFatal?: boolean): void;
  enableAutomaticIssueSubmission(enable?: boolean): void;
  isAutomaticIssueSubmissionEnabled(): boolean;
}

export interface ILoggingService {
  getRecentLogs(): string;
  addLog(message: string): void;
  clearLogs(): void;
}
export interface INetworkMonitoringService {
  startMonitoring(): void;
  stopMonitoring(): void;
  isMonitoring(): boolean;
  getRecentRequests(count?: number): NetworkRequest[];
  clearRequests(): void;
}

export interface NetworkRequest {
  id: string;
  url: string;
  method: string;
  headers?: Record<string, string>;
  body?: string;
  startTime: number;
  endTime?: number;
  status?: number;
  response?: string;
  error?: string;
  duration?: number;
}
