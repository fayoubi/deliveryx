//
//  LocationSetupViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit

/// Step 2/5: Location Setup - Creates location and sets operating hours
class LocationSetupViewController: UIViewController {

    // MARK: - Properties

    /// The store ID passed from previous screen
    private var storeID: String!

    /// Text field for location name
    private var nameTextField: UITextField!

    /// Text field for address
    private var addressTextField: UITextField!

    /// Text field for city
    private var cityTextField: UITextField!

    /// Text field for phone number
    private var phoneTextField: UITextField!

    /// Table view for operating hours
    private var operatingHoursTableView: UITableView!

    /// Submit button
    private var submitButton: UIButton!

    /// Operating hours data for each day of the week
    private var operatingHoursData: [DayOfWeek: OperatingHourInput] = [:]

    /// Restaurant service for API calls
    private let restaurantService = RestaurantService.shared

    /// Loading indicator view
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    // MARK: - Configuration

    /// Configures the view controller with store ID
    /// - Parameter storeID: The ID of the store
    func configure(storeID: String) {
        self.storeID = storeID
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Location Setup (2/5)"
        view.backgroundColor = .systemBackground

        setupDefaultOperatingHours()
        setupUI()
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

        // Location Name Text Field
        nameTextField = UITextField()
        nameTextField.placeholder = "Location Name *"
        nameTextField.borderStyle = .roundedRect
        nameTextField.font = UIFont.systemFont(ofSize: 16)
        nameTextField.delegate = self
        mainStackView.addArrangedSubview(nameTextField)

        // Address Text Field
        addressTextField = UITextField()
        addressTextField.placeholder = "Street Address *"
        addressTextField.borderStyle = .roundedRect
        addressTextField.font = UIFont.systemFont(ofSize: 16)
        addressTextField.delegate = self
        mainStackView.addArrangedSubview(addressTextField)

        // City Text Field
        cityTextField = UITextField()
        cityTextField.placeholder = "City *"
        cityTextField.borderStyle = .roundedRect
        cityTextField.font = UIFont.systemFont(ofSize: 16)
        cityTextField.delegate = self
        mainStackView.addArrangedSubview(cityTextField)

        // Phone Text Field
        phoneTextField = UITextField()
        phoneTextField.placeholder = "Phone Number (optional)"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.font = UIFont.systemFont(ofSize: 16)
        phoneTextField.keyboardType = .phonePad
        phoneTextField.delegate = self
        mainStackView.addArrangedSubview(phoneTextField)

        // Operating Hours Section Label
        let operatingHoursLabel = UILabel()
        operatingHoursLabel.text = "Operating Hours"
        operatingHoursLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainStackView.addArrangedSubview(operatingHoursLabel)

        // Operating Hours Table View
        operatingHoursTableView = UITableView()
        operatingHoursTableView.delegate = self
        operatingHoursTableView.dataSource = self
        operatingHoursTableView.layer.borderColor = UIColor.systemGray4.cgColor
        operatingHoursTableView.layer.borderWidth = 1
        operatingHoursTableView.layer.cornerRadius = 8
        operatingHoursTableView.isScrollEnabled = false
        mainStackView.addArrangedSubview(operatingHoursTableView)

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
            addressTextField.heightAnchor.constraint(equalToConstant: 44),
            cityTextField.heightAnchor.constraint(equalToConstant: 44),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),

            // Operating Hours Table View Height (7 rows * 44 height)
            operatingHoursTableView.heightAnchor.constraint(equalToConstant: 308),

            // Submit Button Height
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // Safety check: Verify all UI elements are properly initialized
        guard nameTextField != nil,
              addressTextField != nil,
              cityTextField != nil,
              phoneTextField != nil,
              operatingHoursTableView != nil,
              submitButton != nil else {
            print("Error: Failed to initialize all UI elements")
            return
        }

        print("LocationSetup UI setup completed successfully")
    }

    /// Sets up default operating hours (9:00 AM - 9:00 PM, all days open)
    private func setupDefaultOperatingHours() {
        for day in DayOfWeek.allCases {
            operatingHoursData[day] = OperatingHourInput(
                dayOfWeek: day,
                openTime: "09:00",
                closeTime: "21:00",
                isClosed: false
            )
        }
    }

    // MARK: - Validation

    /// Validates the location setup form
    /// - Returns: True if form is valid, false otherwise
    private func validateForm() -> Bool {
        // Safety check: Ensure UI elements are initialized
        guard let nameTextField = nameTextField,
              let addressTextField = addressTextField,
              let cityTextField = cityTextField,
              let phoneTextField = phoneTextField else {
            print("Error: UI elements not properly initialized")
            showAlert(title: "Error", message: "Form is not properly initialized")
            return false
        }

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty else {
            showAlert(title: "Validation Error", message: "Location name is required")
            return false
        }

        guard let address = addressTextField.text?.trimmingCharacters(in: .whitespaces),
              !address.isEmpty else {
            showAlert(title: "Validation Error", message: "Address is required")
            return false
        }

        guard let city = cityTextField.text?.trimmingCharacters(in: .whitespaces),
              !city.isEmpty else {
            showAlert(title: "Validation Error", message: "City is required")
            return false
        }

        // Validate phone number format if provided
        if let phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces),
           !phone.isEmpty {
            let phoneRegex = Constants.Validation.phonePattern
            let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if !phonePredicate.evaluate(with: phone) {
                showAlert(title: "Validation Error", message: "Please enter a valid phone number")
                return false
            }
        }

        return true
    }

    // MARK: - Actions

    /// Handles submit button tap
    @objc private func submitButtonTapped() {
        guard validateForm() else { return }
        createLocationAndSetHours()
    }

    /// Dismisses the keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - API Integration

    /// Creates location and then sets operating hours
    private func createLocationAndSetHours() {
        // Safety check: Ensure UI elements are initialized
        guard let nameTextField = nameTextField,
              let addressTextField = addressTextField,
              let cityTextField = cityTextField,
              let phoneTextField = phoneTextField else {
            showAlert(title: "Error", message: "Form is not properly initialized")
            return
        }

        // Safety check: Ensure restaurant service is available
        guard restaurantService != nil else {
            showAlert(title: "Error", message: "Restaurant service is not available")
            return
        }

        showLoading("Creating location...")

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              let address = addressTextField.text?.trimmingCharacters(in: .whitespaces),
              let city = cityTextField.text?.trimmingCharacters(in: .whitespaces) else {
            hideLoading()
            showAlert(title: "Error", message: "Please fill in all required fields")
            return
        }

        let phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces)

        let request = CreateLocationRequest(
            name: name,
            address: address,
            city: city,
            state: nil, // TODO: Add state field if needed
            postalCode: nil, // TODO: Add postal code field if needed
            country: "US", // TODO: Add country picker or default
            latitude: nil, // TODO: Add geocoding integration
            longitude: nil,
            phone: phone?.isEmpty == false ? phone : nil,
            isActive: true,
            operatingHours: nil // Will be set separately
        )

        restaurantService.createLocation(storeID: storeID, request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let location):
                    // Location created, now set operating hours
                    self?.setOperatingHours(locationID: location.id)

                case .failure(let error):
                    self?.hideLoading()
                    self?.showAlert(
                        title: "Error",
                        message: "Failed to create location: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Sets operating hours for the location
    /// - Parameter locationID: The ID of the created location
    private func setOperatingHours(locationID: String) {
        showLoading("Setting operating hours...")

        let hours = DayOfWeek.allCases.compactMap { operatingHoursData[$0] }

        restaurantService.setOperatingHours(
            locationID: locationID,
            hours: hours
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()

                switch result {
                case .success:
                    self?.navigateToCollectionSelection(locationID: locationID)

                case .failure(let error):
                    self?.showAlert(
                        title: "Error",
                        message: "Location created but failed to set hours: \(error.localizedDescription). You can continue anyway."
                    )
                    // Allow user to continue even if operating hours failed
                    self?.navigateToCollectionSelection(locationID: locationID)
                }
            }
        }
    }

    // MARK: - Navigation

    /// Navigates to Collection Selection screen
    /// - Parameter locationID: The ID of the created location
    private func navigateToCollectionSelection(locationID: String) {
        // Safety check: Ensure locationID is valid
        guard !locationID.isEmpty else {
            showAlert(title: "Error", message: "Invalid location ID")
            return
        }

        // Safety check: Ensure navigation controller is available
        guard let navigationController = navigationController else {
            showAlert(title: "Error", message: "Navigation is not available")
            return
        }

        let collectionSelectionVC = CollectionSelectionViewController()
        collectionSelectionVC.configure(locationID: locationID)
        navigationController.pushViewController(collectionSelectionVC, animated: true)
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

// MARK: - UITableViewDataSource

extension LocationSetupViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayOfWeek.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Implement custom cell for operating hours
        // - Show day name (Monday, Tuesday, etc.)
        // - Show open/closed switch
        // - Show open time picker
        // - Show close time picker
        // - Update operatingHoursData when values change

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "OperatingHourCell")
        let day = DayOfWeek.allCases[indexPath.row]
        let hourData = operatingHoursData[day]

        cell.textLabel?.text = day.rawValue.capitalized
        if let hourData = hourData, !hourData.isClosed {
            cell.detailTextLabel?.text = "\(hourData.openTime ?? "09:00") - \(hourData.closeTime ?? "21:00")"
        } else {
            cell.detailTextLabel?.text = "Closed"
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension LocationSetupViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // TODO: Show time picker or detailed edit screen for operating hours
        // - Allow user to set open time, close time, or mark as closed
        // - Update operatingHoursData when done
    }
}

// MARK: - UITextFieldDelegate

extension LocationSetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
