import { NitroModules } from 'react-native-nitro-modules';
import type { Toadly } from './Toadly.nitro';
import LoggingService from './LoggingService';

const ToadlyHybridObject = NitroModules.createHybridObject<Toadly>('Toadly');

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
  LoggingService.addLog(`Setting up Toadly with GitHub integration`);
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
