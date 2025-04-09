import Foundation
import UIKit

class CrashUtil {
    static func triggerCrash() {
        LoggingService.info("Intentionally crashing the native iOS app")
        
        // Notify the crash reporter that this is an intentional crash
        CrashReporter.handleIntentionalCrash()
        
        // Give a small delay to ensure the log is written before crashing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Force an exception - this will crash the app
            let array: [Int] = []
            let _ = array[10] // This will cause an index out of bounds exception
            
            // Alternative crash methods:
            // fatalError("Intentional crash for testing")
            // let pointer: UnsafeMutablePointer<Int>? = nil
            // pointer!.pointee = 0 // Force unwrap nil pointer
        }
    }
}
