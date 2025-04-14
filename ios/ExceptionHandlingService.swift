import Foundation
import UIKit

// Constants
let ToadlyUncaughtExceptionHandlerSignalExceptionName = "ToadlyUncaughtExceptionHandlerSignalExceptionName"
let ToadlyUncaughtExceptionHandlerSignalKey = "ToadlyUncaughtExceptionHandlerSignalKey"
let ToadlyUncaughtExceptionHandlerAddressesKey = "ToadlyUncaughtExceptionHandlerAddressesKey"

// Global variables
private var dismissApp = true
private var uncaughtExceptionCount: Int32 = 0
private let uncaughtExceptionMaximum: Int32 = 10
private let skipAddressCount = 4
private let reportAddressCount = 5

// Callback blocks
private var nativeErrorCallbackBlock: ((NSException, String) -> Void)?
private var previousNativeErrorCallbackBlock: (@convention(c) (NSException) -> Void)?
private var callPreviousNativeErrorCallbackBlock = false
private var jsErrorCallbackBlock: ((NSException, String) -> Void)?

// Default native error handler
private let defaultNativeErrorCallbackBlock: ((NSException, String) -> Void) = { exception, readableException in
    DispatchQueue.main.async {
        let alert = UIAlertController(
            title: "Unexpected error occurred",
            message: "Apologies..The app will close now \nPlease restart the app\n\n\(readableException)",
            preferredStyle: .alert
        )
        
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            ExceptionHandlingService.releaseExceptionHold()
        }
    }
}

@objc public class ExceptionHandlingService: NSObject {
    
    @objc public static func setupExceptionHandler(callPreviousHandler: Bool = false) {
        // Store the previous exception handler
        previousNativeErrorCallbackBlock = NSGetUncaughtExceptionHandler()
        callPreviousNativeErrorCallbackBlock = callPreviousHandler
        
        // Set our custom exception handler
        NSSetUncaughtExceptionHandler(handleException)
        
        // Set up signal handlers
        signal(SIGABRT, signalHandler)
        signal(SIGILL, signalHandler)
        signal(SIGSEGV, signalHandler)
        signal(SIGFPE, signalHandler)
        signal(SIGBUS, signalHandler)
        // Not setting SIGPIPE as it can cause issues
        
        print("[Toadly] Registered native exception handler")
    }
    
    @objc public static func setCustomExceptionHandler(_ handler: @escaping (NSException, String) -> Void) {
        nativeErrorCallbackBlock = handler
    }
    
    @objc public static func setJSExceptionCallback(_ callback: @escaping (NSException, String) -> Void) {
        jsErrorCallbackBlock = callback
    }
    
    @objc public static func releaseExceptionHold() {
        dismissApp = true
        print("[Toadly] Releasing locked exception handler")
    }
    
    // Handle the exception on the main thread
    @objc func handleExceptionInternal(_ exception: NSException) {
        let callStack = exception.callStackSymbols
        let readableError = "\(exception.reason ?? "Unknown reason")\n\(callStack.joined(separator: "\n"))"
        
        dismissApp = false
        
        // Call previous handler if requested
        if callPreviousNativeErrorCallbackBlock, let previousHandler = previousNativeErrorCallbackBlock {
            previousHandler(exception)
        }
        
        // Call custom native handler or default
        if let customHandler = nativeErrorCallbackBlock {
            customHandler(exception, readableError)
        } else {
            defaultNativeErrorCallbackBlock(exception, readableError)
        }
        
        // Call JS callback if available
        jsErrorCallbackBlock?(exception, readableError)
        
        // Keep the app alive to show the error
        let runLoop = CFRunLoopGetCurrent()
        let allModes = CFRunLoopCopyAllModes(runLoop)
        
        while !dismissApp {
            for i in 0..<CFArrayGetCount(allModes) {
                let mode = unsafeBitCast(
                    CFArrayGetValueAtIndex(allModes, i),
                    to: CFRunLoopMode.self
                )
                CFRunLoopRunInMode(mode, 0.001, false)
            }
        }
        
        // Clean up and terminate
        NSSetUncaughtExceptionHandler(nil)
        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        
        if let signalValue = exception.userInfo?[ToadlyUncaughtExceptionHandlerSignalKey] as? NSNumber {
          kill(getpid(), Int32(signalValue.intValue))
        }
    }
    
    // Get backtrace for the current thread
    @objc public static func backtrace() -> [String] {
        var callstack = [UnsafeMutableRawPointer?](repeating: nil, count: 128)
        let frames = Darwin.backtrace(&callstack, 128)
        let strs = backtrace_symbols(&callstack, frames)!
        
        var backtrace = [String]()
      for i in skipAddressCount..<min(skipAddressCount + reportAddressCount, Int(frames)) {
            if let symbol = strs[i] {
                backtrace.append(String(cString: symbol))
            }
        }
        
        return backtrace
    }
    
    // Integration with Toadly
    @objc public static func setupWithToadly() {
        setupExceptionHandler()
        
        // Set a custom handler that will create GitHub issues
        setCustomExceptionHandler { exception, readableError in
            // Create a GitHub issue with the crash details
            DispatchQueue.global(qos: .background).async {
                if let toadly = Toadly.shared {
                    let title = "iOS Crash: \(exception.name.rawValue)"
                    let reportType = "crash"
                    
                    // Create GitHub issue
                    do {
                        try toadly.createIssueWithTitle(
                            title: title,
                            reportType: reportType
                        )
                    } catch {
                        print("[Toadly] Failed to create GitHub issue: \(error.localizedDescription)")
                    }
                    
                    // Give some time for the report to be sent
                    Thread.sleep(forTimeInterval: 3.0)
                }
            }
            
            // Also show the default alert
            defaultNativeErrorCallbackBlock(exception, readableError)
        }
    }
}

// Global C functions for exception handling
private func handleException(exception: NSException) {
    let exceptionCount = OSAtomicIncrement32(&uncaughtExceptionCount)
    if exceptionCount > uncaughtExceptionMaximum {
        return
    }
    
    let callStack = ExceptionHandlingService.backtrace()
    var userInfo = exception.userInfo ?? [:]
    userInfo[ToadlyUncaughtExceptionHandlerAddressesKey] = callStack
    
    let exceptionWithCallstack = NSException(
        name: exception.name,
        reason: exception.reason,
        userInfo: userInfo
    )
    
    let handler = ExceptionHandlingService()
    handler.performSelector(
        onMainThread: #selector(ExceptionHandlingService.handleExceptionInternal(_:)),
        with: exceptionWithCallstack,
        waitUntilDone: true
    )
}

private func signalHandler(signal: Int32) {
    let exceptionCount = OSAtomicIncrement32(&uncaughtExceptionCount)
    if exceptionCount > uncaughtExceptionMaximum {
        return
    }
    
    let callStack = ExceptionHandlingService.backtrace()
    let userInfo: [String: Any] = [
        ToadlyUncaughtExceptionHandlerSignalKey: NSNumber(value: signal),
        ToadlyUncaughtExceptionHandlerAddressesKey: callStack
    ]
    
    let exception = NSException(
        name: NSExceptionName(rawValue: ToadlyUncaughtExceptionHandlerSignalExceptionName),
        reason: "Signal \(signal) was raised.",
        userInfo: userInfo
    )
    
    let handler = ExceptionHandlingService()
    handler.performSelector(
        onMainThread: #selector(ExceptionHandlingService.handleExceptionInternal(_:)),
        with: exception,
        waitUntilDone: true
    )
}
