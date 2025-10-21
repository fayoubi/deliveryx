//
//  LocationSetupViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit
import SVProgressHUD

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
        // TODO: Implement UI layout using Auto Layout or Storyboard
        // - Create UIScrollView to contain all content
        // - Add name text field with placeholder "Location Name"
        // - Add address text field with placeholder "Street Address"
        // - Add city text field with placeholder "City"
        // - Add phone text field with placeholder "Phone Number (optional)"
        // - Add section header label "Operating Hours"
        // - Add table view for 7 days of operating hours
        // - Add submit button with title "Continue"
        // - Configure table view delegate and data source
        // - Register custom cell for operating hours
        // - Add tap gesture to dismiss keyboard
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

        // TODO: Add more validation rules
        // - Validate phone number format if provided
        // - Validate operating hours times format
        // - Ensure at least one day is open
        // - Validate open time is before close time

        return true
    }

    // MARK: - Actions

    /// Handles submit button tap
    @objc private func submitButtonTapped() {
        guard validateForm() else { return }
        createLocationAndSetHours()
    }

    // MARK: - API Integration

    /// Creates location and then sets operating hours
    private func createLocationAndSetHours() {
        SVProgressHUD.show(withStatus: "Creating location...")

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              let address = addressTextField.text?.trimmingCharacters(in: .whitespaces),
              let city = cityTextField.text?.trimmingCharacters(in: .whitespaces) else {
            SVProgressHUD.dismiss()
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
                    SVProgressHUD.dismiss()
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
        SVProgressHUD.setStatus("Setting operating hours...")

        let hours = DayOfWeek.allCases.compactMap { operatingHoursData[$0] }

        restaurantService.setOperatingHours(
            locationID: locationID,
            hours: hours
        ) { [weak self] result in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()

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
        let collectionSelectionVC = CollectionSelectionViewController()
        collectionSelectionVC.configure(locationID: locationID)
        navigationController?.pushViewController(collectionSelectionVC, animated: true)
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
