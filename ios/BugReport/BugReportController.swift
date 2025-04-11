import UIKit

class BugReportController {
    private var formView: BugReportFormView?
    private var onSubmit: ((String, String, String, BugReportType) -> Void)?
    private var onCancel: (() -> Void)?
    
    // Store the original center Y constraint for keyboard adjustments
    private var formCenterYConstraint: NSLayoutConstraint?
    
    func show(
        from viewController: UIViewController,
        onSubmit: @escaping (String, String, String, BugReportType) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onCancel = onCancel
        
        DispatchQueue.main.async {
            // Create and configure the form view
            let formView = BugReportFormView(frame: viewController.view.bounds)
            formView.translatesAutoresizingMaskIntoConstraints = false
            formView.alpha = 0
            
            // Set callbacks
            formView.onSubmit = { [weak self] email, reportType, description in
                self?.handleSubmit(email: email, reportType: reportType, description: description)
            }
            
            formView.onDismiss = { [weak self] in
                self?.dismissForm(animated: true)
            }
            
            // Set keyboard callbacks
            formView.onKeyboardWillShow = { [weak self] keyboardFrame in
                self?.adjustForKeyboard(keyboardFrame: keyboardFrame, viewController: viewController)
            }
            
            formView.onKeyboardWillHide = { [weak self] in
                self?.resetFormPosition(viewController: viewController)
            }
            
            // Add to view hierarchy
            viewController.view.addSubview(formView)
            
            // Set constraints
            let centerYConstraint = formView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
            self.formCenterYConstraint = centerYConstraint
            
            NSLayoutConstraint.activate([
                formView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                formView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                formView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                formView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])
            
            // Animate in
            UIView.animate(withDuration: 0.3) {
                formView.alpha = 1
            }
            
            self.formView = formView
        }
    }
    
    private func adjustForKeyboard(keyboardFrame: CGRect, viewController: UIViewController) {
        guard let formView = formView else { return }
        
        // Get the form container view
        if let containerView = formView.subviews.first(where: { $0.backgroundColor == .white }) {
            // Calculate if the keyboard overlaps with the form
            let containerFrame = containerView.convert(containerView.bounds, to: viewController.view)
            
            // Check if the keyboard overlaps with the form
            let overlap = containerFrame.maxY - keyboardFrame.minY
            
            if overlap > 0 {
                // Move the form up by the overlap amount plus some padding
                let padding: CGFloat = 20
                UIView.animate(withDuration: 0.3) {
                    containerView.transform = CGAffineTransform(translationX: 0, y: -overlap - padding)
                }
            }
        }
    }
    
    private func resetFormPosition(viewController: UIViewController) {
        guard let formView = formView else { return }
        
        // Reset the form position
        if let containerView = formView.subviews.first(where: { $0.backgroundColor == .white }) {
            UIView.animate(withDuration: 0.3) {
                containerView.transform = .identity
            }
        }
    }
    
    private func handleSubmit(email: String, reportType: BugReportType, description: String) {
        // Generate a default title from the first line or first few words of the description
        let title = generateTitleFromDescription(description, reportType: reportType)
        
        // Call the completion handler
        onSubmit?(email, title, description, reportType)
        
        // Dismiss the form
        dismissForm(animated: true)
    }
    
    private func generateTitleFromDescription(_ description: String, reportType: BugReportType) -> String {
        // Use the first line if it exists and isn't too long
        let firstLine = description.split(separator: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var title = ""
        
        if !firstLine.isEmpty && firstLine.count <= 50 {
            title = firstLine
        } else {
            // Otherwise use the first few words (up to 50 characters)
            let words = description.split(separator: " ")
            
            for word in words {
                if (title + " " + word).count <= 50 {
                    if !title.isEmpty {
                        title += " "
                    }
                    title += word
                } else {
                    break
                }
            }
            
            if title.isEmpty {
                title = reportType.rawValue
            }
        }
        
        return title
    }
    
    func dismissForm(animated: Bool) {
        guard let formView = formView else { return }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                formView.alpha = 0
            }, completion: { _ in
                formView.removeFromSuperview()
                self.formView = nil
                self.onCancel?()
            })
        } else {
            formView.removeFromSuperview()
            self.formView = nil
            self.onCancel?()
        }
    }
}
