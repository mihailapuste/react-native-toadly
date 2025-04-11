import UIKit

class BugReportFormView: UIView {
    // UI Components
    private let containerView = UIView()
    private let emailTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    
    // Callbacks
    var onSubmit: ((String, String) -> Void)?
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
        // Setup background
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Setup container view
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
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
        
        // Setup submit button
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0) // Green color
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        containerView.addSubview(submitButton)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
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
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            
            // Email text field constraints
            emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Description text view constraints
            descriptionTextView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            
            // Submit button constraints
            submitButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
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
    
    @objc private func keyboardWillHide(notification: NSNotification) {
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
        
        onSubmit?(email, description)
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
