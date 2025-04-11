import UIKit

class BugReportFormView: UIView {
    // UI Components
    private let containerView = UIView()
    private let headerView = UIView()
    private let closeButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let emailTextField = UITextField()
    private let reportTypeButton = UIButton(type: .system)
    private let descriptionTextView = UITextView()
    
    // State
    private var selectedReportType: BugReportType = .bug
    
    // Callbacks
    var onSubmit: ((String, BugReportType, String) -> Void)?
    var onDismiss: (() -> Void)?
    var onKeyboardWillShow: ((CGRect) -> Void)?
    var onKeyboardWillHide: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupKeyboardNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Setup background with blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add a semi-transparent black overlay for additional darkness
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        // Make sure blur effect is behind everything else
        insertSubview(blurEffectView, at: 0)
        
        // Setup container view
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Setup header view
        headerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light gray background
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        // We don't need to set corner radius on the header view since the container view handles clipping
        containerView.addSubview(headerView)
        
        // Setup close button
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .darkGray
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(closeButton)
        
        // Setup submit button (circular)
        submitButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        submitButton.tintColor = .systemBlue
        submitButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0) // Light blue background
        submitButton.layer.cornerRadius = 20 // Make it circular
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(submitButton)
        
        // Setup email text field
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(emailTextField)
        
        // Setup report type button
        reportTypeButton.setTitle(selectedReportType.displayText, for: .normal)
        reportTypeButton.contentHorizontalAlignment = .left
        reportTypeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        reportTypeButton.layer.borderWidth = 0.5
        reportTypeButton.layer.borderColor = UIColor.lightGray.cgColor
        reportTypeButton.layer.cornerRadius = 5
        reportTypeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        reportTypeButton.setTitleColor(.black, for: .normal)
        reportTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup the dropdown menu
        let bugAction = UIAction(title: BugReportType.bug.displayText, image: nil, handler: { [weak self] _ in
            self?.selectedReportType = .bug
            self?.reportTypeButton.setTitle(BugReportType.bug.displayText, for: .normal)
        })
        
        let suggestionAction = UIAction(title: BugReportType.suggestion.displayText, image: nil, handler: { [weak self] _ in
            self?.selectedReportType = .suggestion
            self?.reportTypeButton.setTitle(BugReportType.suggestion.displayText, for: .normal)
        })
        
        let questionAction = UIAction(title: BugReportType.question.displayText, image: nil, handler: { [weak self] _ in
            self?.selectedReportType = .question
            self?.reportTypeButton.setTitle(BugReportType.question.displayText, for: .normal)
        })
        
        let menu = UIMenu(title: "", options: .displayInline, children: [bugAction, suggestionAction, questionAction])
        reportTypeButton.menu = menu
        reportTypeButton.showsMenuAsPrimaryAction = true
        
        containerView.addSubview(reportTypeButton)
        
        // Setup description text view
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.delegate = self
        containerView.addSubview(descriptionTextView)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        
        // Add tap gesture to dismiss the form when tapping outside
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundTapGesture.cancelsTouchesInView = false
        addGestureRecognizer(backgroundTapGesture)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9), // Increased from fixed 350 to 90% of parent width
            
            // Header view constraints
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Close button constraints
            closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12), // Reduced from 16
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Submit button constraints
            submitButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12), // Reduced from 16
            submitButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 40),
            submitButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Email text field constraints
            emailTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12), // Reduced from 16
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12), // Reduced from 16
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Report type button constraints
            reportTypeButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            reportTypeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12), // Reduced from 16
            reportTypeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12), // Reduced from 16
            reportTypeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Description text view constraints
            descriptionTextView.topAnchor.constraint(equalTo: reportTypeButton.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12), // Reduced from 16
            descriptionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12), // Reduced from 16
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            descriptionTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            onKeyboardWillShow?(keyboardFrame)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        onKeyboardWillHide?()
    }
    
    // MARK: - Actions
    
    @objc private func submitButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            // Show error for empty email
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.6
            animation.values = [-10, 10, -10, 10, -5, 5, -2.5, 2.5, 0]
            containerView.layer.add(animation, keyPath: "shake")
            return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty, description != "Description" else {
            // Show error for empty description
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.6
            animation.values = [-10, 10, -10, 10, -5, 5, -2.5, 2.5, 0]
            containerView.layer.add(animation, keyPath: "shake")
            return
        }
        
        onSubmit?(email, selectedReportType, description)
    }
    
    @objc private func closeButtonTapped() {
        onDismiss?()
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    @objc private func backgroundTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !containerView.frame.contains(location) {
            onDismiss?()
        }
    }
    
    // Helper to find the view controller that contains this view
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

// MARK: - UITextFieldDelegate
extension BugReportFormView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            descriptionTextView.becomeFirstResponder()
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension BugReportFormView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = .lightGray
        }
    }
}

// MARK: - Animation Extension
extension CALayer {
    func add(_ animation: CAAnimation, keyPath: String) {
        add(animation, forKey: keyPath)
    }
}
