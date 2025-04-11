import type { IErrorHandlingService } from './interfaces';
import { NitroModules } from 'react-native-nitro-modules';
import type { Toadly } from '../Toadly.nitro';
import { LoggingService } from './index';
import { ErrorTypes } from './types';

const ToadlyHybridObject = NitroModules.createHybridObject<Toadly>('Toadly');

class ErrorHandlingService implements IErrorHandlingService {
  private static instance: ErrorHandlingService;
  private isErrorHandlingSetup: boolean = false;
  private autoSubmitIssues: boolean = false;

  private constructor() {
    this.setupErrorHandling();
  }

  public static getInstance(): ErrorHandlingService {
    if (!ErrorHandlingService.instance) {
      ErrorHandlingService.instance = new ErrorHandlingService();
    }
    return ErrorHandlingService.instance;
  }

  private setupErrorHandling() {
    if (this.isErrorHandlingSetup || typeof global === 'undefined') {
      return;
    }

    this.isErrorHandlingSetup = true;
    
    try {
      // @ts-ignore Access ErrorUtils directly from the global scope
      const ErrorUtils = global.ErrorUtils;
      
      if (ErrorUtils) { 
        const defaultErrorHandler = ErrorUtils.getGlobalHandler();
        
        // Override the global error handler
        ErrorUtils.setGlobalHandler((error: Error, isFatal?: boolean) => {
          this.captureJSCrash(error, isFatal);
          
          if (this.autoSubmitIssues && isFatal) {
            this.createIssue(error, isFatal);
          }
          
          // Call the default handler afterwards
          defaultErrorHandler(error, isFatal);
        });
      }
    } catch (error) {
      console.warn('Error setting up React Native error handler:', error);
    }
  }

  /**
   * Capture JavaScript crash information
   */
  public captureJSCrash(error: Error, isFatal: boolean = false): void {
    try {
      const timestamp = new Date().toISOString();
      const errorType = isFatal ? ErrorTypes.FATAL_CRASH : ErrorTypes.NON_FATAL_ERROR;
      
      const errorMessage = error.message || `${error}`;
      const stackTrace = error.stack || '';
      
      const crashLog = [
        `[${timestamp}] [${errorType}] ${errorMessage}`,
        stackTrace ? `Stack trace:\n${stackTrace}` : ''
      ].filter(Boolean).join('\n');
      
      LoggingService.addLog(crashLog);
    } catch (captureError) {
      console.error('Error capturing JS crash:', captureError);
    }
  }

  public createIssue(error: Error, isFatal: boolean = false): void {
    try {
      const errorType = isFatal ? ErrorTypes.FATAL_CRASH : ErrorTypes.NON_FATAL_ERROR;
      const title = `[${errorType}] ${error.message.substring(0, 100)}`;
      
      // Delay to ensure all logs are captured
      setTimeout(() => {
        const jsLogs = LoggingService.getRecentLogs();
        ToadlyHybridObject.addJSLogs(jsLogs);
        
        ToadlyHybridObject.createIssueWithTitle(title, 'crash');
      }, 100);
    } catch (submitError) {
      console.error('Error submitting GitHub issue:', submitError);
    }
  }

  public enableAutomaticIssueSubmission(enable: boolean = true): void {
    this.autoSubmitIssues = enable;
  }

  public isAutomaticIssueSubmissionEnabled(): boolean {
    return this.autoSubmitIssues;
  }
}

export default ErrorHandlingService.getInstance();
