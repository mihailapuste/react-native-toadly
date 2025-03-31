import UIKit
import NitroModules

class Toadly: HybridToadlySpec {
    private let bugReportDialog = BugReportDialog()

    public func multiply(a: Double, b: Double) throws -> Double {
        return a * b
    }

    public func show() throws {
        guard let rootViewController = BugReportDialog.getRootViewController() else {
            return
        }

        bugReportDialog.show(
            from: rootViewController,
            onSubmit: { email, title, details in
                print("Bug Report Submitted:")
                print("Email: \(email)")
                print("Title: \(title)")
                print("Details: \(details)")
            },
            onCancel: {
                print("Bug report cancelled")
            }
        )
    }
}
