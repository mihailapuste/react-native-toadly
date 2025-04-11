export interface ConsoleOverrides {
  log: typeof console.log;
  info: typeof console.info;
  warn: typeof console.warn;
  error: typeof console.error;
}

export enum ErrorTypes {
  FATAL_CRASH = 'FATAL CRASH',
  NON_FATAL_ERROR = 'NON-FATAL ERROR',
}

export enum LogTypes {
  LOG = 'LOG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR',
  TOADLY = '🐸',
}
