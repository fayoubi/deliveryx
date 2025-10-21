//
//  ReviewSubmitViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit
import SVProgressHUD

/// Step 5/5: Review & Submit - Reviews complete menu and submits for publishing
class ReviewSubmitViewController: UIViewController {

    // MARK: - Properties

    /// The menu ID passed from previous screen
    private var menuID: String!

    /// Table view for displaying menu collections and products
    private var menuTableView: UITableView!

    /// Submit button
    private var submitButton: UIButton!

    /// The complete menu data
    private var completeMenu: CompleteMenu?

    /// Menu service for API calls
    private let menuService = MenuService.shared

    // MARK: - Configuration

    /// Configures the view controller with menu ID
    /// - Parameter menuID: The ID of the menu
    func configure(menuID: String) {
        self.menuID = menuID
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Review & Submit (5/5)"
        view.backgroundColor = .systemBackground

        setupUI()
        loadCompleteMenu()
    }

    // MARK: - UI Setup

    /// Sets up the user interface
    private func setupUI() {
        // TODO: Implement UI layout using Auto Layout or Storyboard
        // - Add header section showing menu summary
        //   - Menu name
        //   - Total collections count
        //   - Total products count
        // - Add table view for displaying collections and products
        //   - Use sections for collections
        //   - Show products in each section
        // - Add submit button with title "Submit Menu for Publishing"
        // - Style table view cells appropriately
        // - Configure table view delegate and data source
    }

    /// Loads the complete menu with all collections and products
    private func loadCompleteMenu() {
        SVProgressHUD.show(withStatus: "Loading menu...")

        menuService.getMenu(menuID: menuID) { [weak self] result in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()

                switch result {
                case .success(let menu):
                    self?.completeMenu = menu
                    self?.menuTableView?.reloadData()
                    self?.updateSummary()

                case .failure(let error):
                    self?.showAlert(
                        title: "Error",
                        message: "Failed to load menu: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Updates the menu summary display
    private func updateSummary() {
        // TODO: Update UI labels showing:
        // - Menu name
        // - Number of collections
        // - Total number of products
        // - Menu status
    }

    // MARK: - Actions

    /// Handles submit button tap
    @objc private func submitButtonTapped() {
        showSubmitConfirmation()
    }

    /// Shows confirmation dialog before submitting
    private func showSubmitConfirmation() {
        guard let menu = completeMenu else { return }

        let totalProducts = menu.collections.reduce(0) { $0 + $1.products.count }

        let message = """
        You are about to submit:

        Collections: \(menu.collections.count)
        Products: \(totalProducts)

        Once submitted, the menu will be published and available to customers.
        """

        let alert = UIAlertController(
            title: "Confirm Submission",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            self?.submitMenu()
        })

        present(alert, animated: true)
    }

    // MARK: - API Integration

    /// Submits the menu for publishing
    private func submitMenu() {
        SVProgressHUD.show(withStatus: "Submitting menu...")

        menuService.submitMenu(menuID: menuID) { [weak self] result in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()

                switch result {
                case .success(let response):
                    self?.showSuccessAndComplete(message: response.message)

                case .failure(let error):
                    self?.showAlert(
                        title: "Submission Failed",
                        message: "Failed to submit menu: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Shows success message and completes onboarding
    /// - Parameter message: Success message from API
    private func showSuccessAndComplete(message: String) {
        let alert = UIAlertController(
            title: "Success!",
            message: "\(message)\n\nYour menu has been published and is now live!",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.completeOnboarding()
        })

        present(alert, animated: true)
    }

    /// Completes the onboarding flow
    private func completeOnboarding() {
        // TODO: Navigate to main app screen or dashboard
        // For now, dismiss the onboarding flow
        navigationController?.dismiss(animated: true) {
            // TODO: Notify app that onboarding is complete
            // - Update user defaults or app state
            // - Show main app interface
        }
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

    /// Formats price for display
    /// - Parameter price: The price to format
    /// - Returns: Formatted price string
    private func formatPrice(_ price: Double) -> String {
        return String(format: "$%.2f", price)
    }
}

// MARK: - UITableViewDataSource

extension ReviewSubmitViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return completeMenu?.collections.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completeMenu?.collections[section].products.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MenuProductCell")

        guard let collection = completeMenu?.collections[indexPath.section] else {
            return cell
        }

        let product = collection.products[indexPath.row]

        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = "\(formatPrice(product.basePrice))\(product.description != nil ? " - \(product.description!)" : "")"
        cell.accessoryType = product.isAvailable ? .checkmark : .none

        // TODO: Add product image to cell if available
        // - Load image asynchronously from product.imageUrl
        // - Display in cell.imageView

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let collection = completeMenu?.collections[section] else {
            return nil
        }

        return "\(collection.name.rawValue) (\(collection.products.count) items)"
    }
}

// MARK: - UITableViewDelegate

extension ReviewSubmitViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // TODO: Optionally show product details or editing options
        // - Display product details in modal
        // - Allow editing product availability
        // - Show full description and image
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let collection = completeMenu?.collections[section] else {
            return nil
        }

        // TODO: Create custom header view
        // - Show collection name prominently
        // - Show product count
        // - Add collection icon if available
        // - Style with background color

        let headerView = UIView()
        headerView.backgroundColor = .systemGray6

        let label = UILabel()
        label.text = "\(collection.name.rawValue) (\(collection.products.count) items)"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }
}
