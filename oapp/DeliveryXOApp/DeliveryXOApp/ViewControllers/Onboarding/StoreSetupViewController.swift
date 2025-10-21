//
//  StoreSetupViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit
import SVProgressHUD

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

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Store Setup (1/5)"
        view.backgroundColor = .systemBackground

        setupUI()
        setupNavigationBar()
    }

    // MARK: - UI Setup

    /// Sets up the user interface
    private func setupUI() {
        // TODO: Implement UI layout using Auto Layout or Storyboard
        // - Create UIStackView or manual constraints
        // - Add name text field with placeholder "Restaurant Name"
        // - Add description text view with placeholder "Description (optional)"
        // - Add phone text field with placeholder "Phone Number (optional)"
        // - Add logo upload button with title "Upload Logo (optional)"
        // - Add logo image view to preview selected image
        // - Add submit button with title "Continue"
        // - Configure text field delegates for validation
        // - Add tap gesture to dismiss keyboard
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
        // Basic validation stub
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty else {
            showAlert(title: "Validation Error", message: "Restaurant name is required")
            return false
        }

        // TODO: Add more validation rules
        // - Validate phone number format if provided
        // - Validate name length (min/max)
        // - Validate description length if provided

        return true
    }

    // MARK: - Actions

    /// Handles upload logo button tap
    @objc private func uploadLogoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
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

    // MARK: - API Integration

    /// Uploads logo image and then creates store
    /// - Parameter logoImage: The logo image to upload
    private func uploadLogoAndCreateStore(logoImage: UIImage) {
        SVProgressHUD.show(withStatus: "Uploading logo...")

        let fileName = "store-logo-\(UUID().uuidString)"

        mediaService.uploadImage(logoImage, fileName: fileName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fileURL):
                    self?.uploadedLogoURL = fileURL
                    self?.createStore()

                case .failure(let error):
                    SVProgressHUD.dismiss()
                    self?.showAlert(
                        title: "Upload Failed",
                        message: "Failed to upload logo: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Creates the store via API
    private func createStore() {
        SVProgressHUD.show(withStatus: "Creating store...")

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces) else {
            SVProgressHUD.dismiss()
            return
        }

        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespaces)
        let phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces)

        // TODO: Get email from logged-in user or add email field
        let email = "owner@example.com" // Placeholder

        let request = CreateStoreRequest(
            name: name,
            email: email,
            phone: phone?.isEmpty == false ? phone : nil,
            description: description?.isEmpty == false ? description : nil,
            logoUrl: uploadedLogoURL
        )

        restaurantService.createStore(request: request) { [weak self] result in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()

                switch result {
                case .success(let store):
                    self?.navigateToLocationSetup(storeID: store.id)

                case .failure(let error):
                    self?.showAlert(
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
        let locationSetupVC = LocationSetupViewController()
        locationSetupVC.configure(storeID: storeID)
        navigationController?.pushViewController(locationSetupVC, animated: true)
    }

    // MARK: - Helper Methods

    /// Shows an alert with title and message
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension StoreSetupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedLogoImage = editedImage
            logoImageView?.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedLogoImage = originalImage
            logoImageView?.image = originalImage
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
