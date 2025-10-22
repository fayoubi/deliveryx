//
//  StoreSetupViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit

/// Step 1/5: Store Setup - Creates the store/restaurant
class StoreSetupViewController: UIViewController {

    // MARK: - Properties

    /// Text field for restaurant name
    private var nameTextField: UITextField!

    /// Text view for description
    private var descriptionTextView: UITextView!

    /// Text field for phone number
    private var phoneTextField: UITextField!

    /// Button to upload logo
    private var uploadLogoButton: UIButton!

    /// Image view to display selected logo
    private var logoImageView: UIImageView!

    /// Submit button
    private var submitButton: UIButton!

    /// Selected logo image
    private var selectedLogoImage: UIImage?

    /// Uploaded logo URL from S3
    private var uploadedLogoURL: String?

    /// Restaurant service for API calls
    private let restaurantService = RestaurantService.shared

    /// Media service for image uploads
    private let mediaService = MediaService.shared

    /// Loading indicator view
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Store Setup (1/5)"
        view.backgroundColor = .systemBackground

        // Safety check: Ensure services are available
        guard restaurantService != nil else {
            print("Error: Restaurant service is not available")
            return
        }
        
        guard mediaService != nil else {
            print("Error: Media service is not available")
            return
        }

        setupUI()
        setupNavigationBar()
    }

    // MARK: - UI Setup

    /// Sets up the user interface
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Create scroll view for content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create content view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Create main stack view
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
        
        // Restaurant Name Text Field
        nameTextField = UITextField()
        nameTextField.placeholder = "Restaurant Name *"
        nameTextField.borderStyle = .roundedRect
        nameTextField.font = UIFont.systemFont(ofSize: 16)
        nameTextField.delegate = self
        mainStackView.addArrangedSubview(nameTextField)
        
        // Description Text View
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Description (optional)"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mainStackView.addArrangedSubview(descriptionLabel)
        
        descriptionTextView = UITextView()
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        descriptionTextView.delegate = self
        mainStackView.addArrangedSubview(descriptionTextView)
        
        // Phone Text Field
        phoneTextField = UITextField()
        phoneTextField.placeholder = "Phone Number (optional)"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.font = UIFont.systemFont(ofSize: 16)
        phoneTextField.keyboardType = .phonePad
        phoneTextField.delegate = self
        mainStackView.addArrangedSubview(phoneTextField)
        
        // Logo Upload Section
        let logoLabel = UILabel()
        logoLabel.text = "Logo (optional)"
        logoLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mainStackView.addArrangedSubview(logoLabel)
        
        uploadLogoButton = UIButton(type: .system)
        uploadLogoButton.setTitle("Upload Logo", for: .normal)
        uploadLogoButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        uploadLogoButton.backgroundColor = .systemBlue
        uploadLogoButton.setTitleColor(.white, for: .normal)
        uploadLogoButton.layer.cornerRadius = 8
        uploadLogoButton.addTarget(self, action: #selector(uploadLogoButtonTapped), for: .touchUpInside)
        mainStackView.addArrangedSubview(uploadLogoButton)
        
        // Logo Image View
        logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .systemGray6
        logoImageView.layer.cornerRadius = 8
        logoImageView.clipsToBounds = true
        logoImageView.isHidden = true
        mainStackView.addArrangedSubview(logoImageView)
        
        // Submit Button
        submitButton = UIButton(type: .system)
        submitButton.setTitle("Continue", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        submitButton.backgroundColor = .systemGreen
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        mainStackView.addArrangedSubview(submitButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Main Stack View
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Text Field Heights
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Description Text View Height
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Upload Button Height
            uploadLogoButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Logo Image View
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Submit Button Height
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Safety check: Verify all UI elements are properly initialized
        guard nameTextField != nil,
              descriptionTextView != nil,
              phoneTextField != nil,
              uploadLogoButton != nil,
              logoImageView != nil,
              submitButton != nil else {
            print("Error: Failed to initialize all UI elements")
            return
        }
        
        print("UI setup completed successfully")
    }

    /// Sets up navigation bar items
    private func setupNavigationBar() {
        // Add cancel button to navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }

    // MARK: - Validation

    /// Validates the store setup form
    /// - Returns: True if form is valid, false otherwise
    private func validateForm() -> Bool {
        // Safety check: Ensure UI elements are initialized
        guard let nameTextField = nameTextField,
              let descriptionTextView = descriptionTextView,
              let phoneTextField = phoneTextField else {
            print("Error: UI elements not properly initialized")
            return false
        }
        
        // Basic validation
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty else {
            showAlert(title: "Validation Error", message: "Restaurant name is required")
            return false
        }

        // Validate name length
        if name.count < Constants.Validation.minNameLength {
            showAlert(title: "Validation Error", message: "Restaurant name must be at least \(Constants.Validation.minNameLength) characters long")
            return false
        }
        
        if name.count > Constants.Validation.maxNameLength {
            showAlert(title: "Validation Error", message: "Restaurant name must be no more than \(Constants.Validation.maxNameLength) characters long")
            return false
        }
        
        // Validate description length if provided
        if let description = descriptionTextView.text?.trimmingCharacters(in: .whitespaces),
           !description.isEmpty && description.count > Constants.Validation.maxDescriptionLength {
            showAlert(title: "Validation Error", message: "Description must be no more than \(Constants.Validation.maxDescriptionLength) characters long")
            return false
        }
        
        // Validate phone number (required)
        guard let phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces),
              !phone.isEmpty else {
            showAlert(title: "Validation Error", message: "Phone number is required")
            return false
        }

        let phoneRegex = Constants.Validation.phonePattern
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !phonePredicate.evaluate(with: phone) {
            showAlert(title: "Validation Error", message: "Please enter a valid phone number (10-15 digits)")
            return false
        }

        return true
    }

    // MARK: - Actions

    /// Handles upload logo button tap
    @objc private func uploadLogoButtonTapped() {
        // Safety check: Ensure we can present the image picker
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(title: "Error", message: "Photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        // Safety check: Ensure we can present the view controller
        guard presentedViewController == nil else {
            print("Warning: Another view controller is already being presented")
            return
        }
        
        present(imagePicker, animated: true)
    }

    /// Handles submit button tap
    @objc private func submitButtonTapped() {
        guard validateForm() else { return }

        // If logo is selected, upload it first, then create store
        if let logoImage = selectedLogoImage {
            uploadLogoAndCreateStore(logoImage: logoImage)
        } else {
            createStore()
        }
    }

    /// Handles cancel button tap
    @objc private func cancelButtonTapped() {
        let alert = UIAlertController(
            title: "Cancel Setup",
            message: "Are you sure you want to cancel? All progress will be lost.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Continue Setup", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) { [weak self] _ in
            self?.navigationController?.dismiss(animated: true)
        })

        present(alert, animated: true)
    }
    
    /// Dismisses the keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - API Integration

    /// Uploads logo image and then creates store
    /// - Parameter logoImage: The logo image to upload
    private func uploadLogoAndCreateStore(logoImage: UIImage) {
        // Safety check: Ensure image is valid
        guard logoImage.size.width > 0 && logoImage.size.height > 0 else {
            showAlert(title: "Error", message: "Invalid image selected")
            return
        }
        
        // Safety check: Ensure media service is available
        guard mediaService != nil else {
            showAlert(title: "Error", message: "Media service is not available")
            return
        }
        
        showLoading("Uploading logo...")

        let fileName = "store-logo-\(UUID().uuidString)"

        mediaService.uploadImage(logoImage, fileName: fileName) { [weak self] result in
            DispatchQueue.main.async {
                // Safety check: Ensure self is still available
                guard let self = self else { return }
                
                switch result {
                case .success(let fileURL):
                    self.uploadedLogoURL = fileURL
                    self.createStore()

                case .failure(let error):
                    self.hideLoading()
                    self.showAlert(
                        title: "Upload Failed",
                        message: "Failed to upload logo: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Creates the store via API
    private func createStore() {
        // Safety check: Ensure UI elements are initialized
        guard let nameTextField = nameTextField,
              let descriptionTextView = descriptionTextView,
              let phoneTextField = phoneTextField else {
            showAlert(title: "Error", message: "Form is not properly initialized")
            return
        }
        
        // Safety check: Ensure restaurant service is available
        guard restaurantService != nil else {
            showAlert(title: "Error", message: "Restaurant service is not available")
            return
        }
        
        showLoading("Creating store...")

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              let phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces) else {
            hideLoading()
            showAlert(title: "Error", message: "Restaurant name and phone are required")
            return
        }

        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespaces)

        // TODO: Get email from logged-in user or add email field
        let email = "owner@example.com" // Placeholder

        let request = CreateStoreRequest(
            name: name,
            email: email,
            phone: phone,
            description: description?.isEmpty == false ? description : nil,
            logoUrl: uploadedLogoURL
        )

        restaurantService.createStore(request: request) { [weak self] result in
            DispatchQueue.main.async {
                // Safety check: Ensure self is still available
                guard let self = self else { return }

                self.hideLoading()

                switch result {
                case .success(let store):
                    self.navigateToLocationSetup(storeID: store.id)

                case .failure(let error):
                    self.showAlert(
                        title: "Error",
                        message: "Failed to create store: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    // MARK: - Navigation

    /// Navigates to Location Setup screen
    /// - Parameter storeID: The ID of the created store
    private func navigateToLocationSetup(storeID: String) {
        // Safety check: Ensure storeID is valid
        guard !storeID.isEmpty else {
            showAlert(title: "Error", message: "Invalid store ID")
            return
        }
        
        // Safety check: Ensure navigation controller is available
        guard let navigationController = navigationController else {
            showAlert(title: "Error", message: "Navigation is not available")
            return
        }
        
        let locationSetupVC = LocationSetupViewController()
        locationSetupVC.configure(storeID: storeID)
        navigationController.pushViewController(locationSetupVC, animated: true)
    }

    // MARK: - Helper Methods

    /// Shows loading indicator with message
    /// - Parameter message: Loading message to display
    private func showLoading(_ message: String = "Loading...") {
        // Remove existing loading view if any
        hideLoading()

        let loading = UIView(frame: view.bounds)
        loading.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        loading.addSubview(indicator)

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        loading.addSubview(label)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: loading.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: loading.centerYAnchor, constant: -20),
            label.centerXAnchor.constraint(equalTo: loading.centerXAnchor),
            label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16)
        ])

        view.addSubview(loading)
        indicator.startAnimating()

        loadingView = loading
        activityIndicator = indicator
    }

    /// Hides the loading indicator
    private func hideLoading() {
        activityIndicator?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
        activityIndicator = nil
    }

    /// Shows an alert with title and message
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    private func showAlert(title: String, message: String) {
        // Safety check: Ensure we can present the alert
        guard presentedViewController == nil else {
            print("Warning: Cannot present alert, another view controller is being presented")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present on main thread to avoid threading issues
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension StoreSetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension StoreSetupViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ""
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension StoreSetupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        // Safety check: Ensure we can dismiss the picker
        guard picker.presentingViewController != nil else {
            print("Warning: Image picker is not being presented")
            return
        }
        
        // Safety check: Get the selected image
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        // Safety check: Ensure we have a valid image
        guard let image = selectedImage else {
            picker.dismiss(animated: true)
            return
        }
        
        // Safety check: Ensure logoImageView is available
        guard let logoImageView = logoImageView else {
            print("Warning: Logo image view is not available")
            picker.dismiss(animated: true)
            return
        }
        
        selectedLogoImage = image
        logoImageView.image = image
        logoImageView.isHidden = false

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Safety check: Ensure we can dismiss the picker
        guard picker.presentingViewController != nil else {
            print("Warning: Image picker is not being presented")
            return
        }
        
        picker.dismiss(animated: true)
    }
}
