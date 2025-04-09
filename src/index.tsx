import { NitroModules } from 'react-native-nitro-modules';
import type { Toadly } from './Toadly.nitro';
import { LoggingService, ErrorHandlingService, NetworkMonitoringService } from './services';

const ToadlyHybridObject = NitroModules.createHybridObject<Toadly>('Toadly');

/**
 * Internal function to create and submit a GitHub issue with a custom title
 * Not exposed in the public API - used internally by error handling
 * @param title The title for the GitHub issue
 */
export const _createIssueWithTitle = (title: string): void => {
  const jsLogs = LoggingService.getRecentLogs();
  ToadlyHybridObject.addJSLogs(jsLogs);
  
  return ToadlyHybridObject.createIssueWithTitle(title);
};

/**
 * Setup the Toadly module with GitHub configuration
 * @param githubToken GitHub access token from environment variables
 * @param repoOwner Repository owner (username or organization)
 * @param repoName Repository name
 */
export function setup(
  githubToken: string,
  repoOwner: string,
  repoName: string
): void {
  return ToadlyHybridObject.setup(githubToken, repoOwner, repoName);
}

/**
 * Shows a bug reporting dialog
 */
export function show(): void {
  LoggingService.addLog('Showing bug report dialog');
  
  // Get JavaScript logs and send them to native side before showing dialog
  const jsLogs = LoggingService.getRecentLogs();
  ToadlyHybridObject.addJSLogs(jsLogs);
  
  return ToadlyHybridObject.show();
}

/**
 * Add a toadly log entry
 * @param message Log message to add
 */
export function log(message: string): void {
  LoggingService.addLog(message);
}

export function clearLogs(): void {
  LoggingService.clearLogs();
}

/**
 * Enable automatic issue submission for JavaScript errors
 * @param enable Whether to enable automatic issue submission
 */
export function enableAutomaticIssueSubmission(enable: boolean = true): void {
  ErrorHandlingService.enableAutomaticIssueSubmission(enable);
}

/**
 * Start monitoring network requests
 * This will capture all fetch and XMLHttpRequest calls
 * Network requests will be included in bug reports
 */
export function startNetworkMonitoring(): void {
  NetworkMonitoringService.getInstance().startMonitoring();
}

/**
 * Stop monitoring network requests
 */
export function stopNetworkMonitoring(): void {
  NetworkMonitoringService.getInstance().stopMonitoring();
}

/**
 * Check if network monitoring is active
 */
export function isNetworkMonitoringActive(): boolean {
  return NetworkMonitoringService.getInstance().isMonitoring();
}

/**
 * Clear network request history
 */
export function clearNetworkHistory(): void {
  NetworkMonitoringService.getInstance().clearRequests();
}

/**
 * Intentionally crash the native iOS app for testing crash reporting
 * This will cause an immediate app crash
 */
export function crashNative(): void {
  return ToadlyHybridObject.crashNative();
}

export { ToadlyHybridObject };
