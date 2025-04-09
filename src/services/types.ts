declare global {
  interface Window {
    ErrorUtils?: {
      getGlobalHandler(): (error: Error, isFatal?: boolean) => void;
      setGlobalHandler(callback: (error: Error, isFatal?: boolean) => void): void;
    };
  }
}

export interface ConsoleOverrides {
  log: typeof console.log;
  info: typeof console.info;
  warn: typeof console.warn;
  error: typeof console.error;
}

export enum ErrorTypes {
  FATAL_CRASH = 'FATAL CRASH',
  NON_FATAL_ERROR = 'NON-FATAL ERROR'
}

export enum LogTypes {
  LOG = 'LOG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR',
  TOADLY = 'TOADLY'
}