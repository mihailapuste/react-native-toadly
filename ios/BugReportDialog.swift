import UIKit

class BugReportDialog {
    private var currentViewController: UIViewController?
    private var onSubmit: ((String, String, String) -> Void)?
    private var onCancel: (() -> Void)?

    func show(
        from viewController: UIViewController,
        onSubmit: @escaping (String, String, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        // Ensure UI updates are on the main thread
        DispatchQueue.main.async {
            self.onSubmit = onSubmit
            self.onCancel = onCancel

            let alertController = UIAlertController(
                title: "Report a Bug",
                message: "Please provide details about the issue you're experiencing",
                preferredStyle: .alert
            )

            alertController.addTextField { textField in
                textField.placeholder = "Your Email"
                textField.keyboardType = .emailAddress
            }

            alertController.addTextField { textField in
                textField.placeholder = "Issue Title"
            }

            alertController.addTextField { textField in
                textField.placeholder = "Issue Details"
            }

            let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
                guard let emailField = alertController.textFields?[0],
                      let titleField = alertController.textFields?[1],
                      let detailsField = alertController.textFields?[2] else {
                    return
                }

                self?.onSubmit?(
                    emailField.text ?? "",
                    titleField.text ?? "",
                    detailsField.text ?? ""
                )

                self?.currentViewController = nil
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.onCancel?()
                self?.currentViewController = nil
            }

            alertController.addAction(submitAction)
            alertController.addAction(cancelAction)

            viewController.present(alertController, animated: true) {
                self.currentViewController = alertController
            }
        }
    }

    static func getRootViewController() -> UIViewController? {
        // Find the root view controller
        // This logic might need adjustment based on your app's navigation structure
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return keyWindow?.rootViewController
    }
}
