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

    static func getRootViewController() -> UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
}
