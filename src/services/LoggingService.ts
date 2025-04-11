import { LogTypes, type ConsoleOverrides } from './types';
import type { ILoggingService } from './interfaces';

/**
 * LoggingService manages log collection and console overrides
 */
class LoggingService implements ILoggingService {
  private static instance: LoggingService;
  private logs: string[] = [];
  private maxLogs: number = 50;
  private originalConsole: ConsoleOverrides = {
    log: console.log,
    info: console.info,
    warn: console.warn,
    error: console.error,
  };
  private isOverridden: boolean = false;

  private constructor() {
    this.setupConsoleOverrides();
  }

  /**
   * Get the singleton instance of LoggingService
   */
  public static getInstance(): LoggingService {
    if (!LoggingService.instance) {
      LoggingService.instance = new LoggingService();
    }
    return LoggingService.instance;
  }

  /**
   * Set up console method overrides to capture logs
   */
  private setupConsoleOverrides() {
    // Only override once to prevent recursion
    if (this.isOverridden) {
      return;
    }

    this.isOverridden = true;

    console.log = (...args: any[]) => {
      this.captureLog(LogTypes.LOG, ...args);
      this.originalConsole.log(...args);
    };

    console.info = (...args: any[]) => {
      this.captureLog(LogTypes.INFO, ...args);
      this.originalConsole.info(...args);
    };

    console.warn = (...args: any[]) => {
      this.captureLog(LogTypes.WARN, ...args);
      this.originalConsole.warn(...args);
    };

    console.error = (...args: any[]) => {
      this.captureLog(LogTypes.ERROR, ...args);
      this.originalConsole.error(...args);
    };
  }

  /**
   * Capture a log entry with timestamp and level
   */
  private captureLog(level: LogTypes, ...args: any[]): void {
    try {
      const timestamp = new Date().toISOString();
      const message = args
        .map((arg) => {
          if (typeof arg === 'object') {
            try {
              return JSON.stringify(arg);
            } catch (e) {
              return String(arg);
            }
          }
          return String(arg);
        })
        .join(' ');

      const formattedLevel =
        level === LogTypes.TOADLY ? LogTypes.TOADLY : `[${level}]`;

      const logEntry = `[${timestamp}] ${formattedLevel} ${message}`;

      this.logs.push(logEntry);

      if (this.logs.length > this.maxLogs) {
        this.logs.shift();
      }
    } catch (error) {
      // Use original console to avoid recursion
      this.originalConsole.error('Error in LoggingService:', error);
    }
  }

  public getRecentLogs(): string {
    return this.logs.join('\n');
  }

  public addLog(message: string): void {
    this.captureLog(LogTypes.TOADLY, message);
  }

  public clearLogs(): void {
    this.logs = [];
  }
}

export default LoggingService.getInstance();
