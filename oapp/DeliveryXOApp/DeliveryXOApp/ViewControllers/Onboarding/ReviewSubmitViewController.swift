//
//  ReviewSubmitViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit

/// Step 5/5: Review & Submit - Reviews complete menu and submits for publishing
class ReviewSubmitViewController: UIViewController {

    // MARK: - Properties

    /// The menu ID passed from previous screen
    private var menuID: String!

    /// Table view for displaying menu collections and products
    private var menuTableView: UITableView!

    /// Submit button
    private var submitButton: UIButton!

    /// Header view with menu summary
    private var headerView: UIView!

    /// Menu name label
    private var menuNameLabel: UILabel!

    /// Collections count label
    private var collectionsCountLabel: UILabel!

    /// Products count label
    private var productsCountLabel: UILabel!

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
        // Header view with summary
        headerView = UIView()
        headerView.backgroundColor = .systemBackground
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        // Menu name label
        menuNameLabel = UILabel()
        menuNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        menuNameLabel.textAlignment = .center
        menuNameLabel.numberOfLines = 0
        menuNameLabel.text = "Menu"
        menuNameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(menuNameLabel)

        // Stats stack view
        let statsStackView = UIStackView()
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 16
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(statsStackView)

        // Collections count
        let collectionsContainer = createStatContainer(title: "Collections", value: "0")
        collectionsCountLabel = collectionsContainer.valueLabel
        statsStackView.addArrangedSubview(collectionsContainer.view)

        // Products count
        let productsContainer = createStatContainer(title: "Products", value: "0")
        productsCountLabel = productsContainer.valueLabel
        statsStackView.addArrangedSubview(productsContainer.view)

        // Separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(separator)

        // Table view
        menuTableView = UITableView(frame: .zero, style: .grouped)
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        menuTableView.delegate = self
        menuTableView.dataSource = self
        view.addSubview(menuTableView)

        // Submit button
        submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit Menu for Publishing", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        submitButton.backgroundColor = .systemGreen
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 12
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)

        // Layout constraints
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Menu name
            menuNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            menuNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            menuNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

            // Stats stack
            statsStackView.topAnchor.constraint(equalTo: menuNameLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

            // Separator
            separator.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 16),
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            // Table view
            menuTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16),

            // Submit button
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    /// Creates a stat container view with title and value labels
    /// - Parameters:
    ///   - title: The title label text
    ///   - value: The initial value
    /// - Returns: Tuple containing the container view and value label
    private func createStatContainer(title: String, value: String) -> (view: UIView, valueLabel: UILabel) {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            container.heightAnchor.constraint(equalToConstant: 80)
        ])

        return (container, valueLabel)
    }

    /// Loads the complete menu with all collections and products
    private func loadCompleteMenu() {
        print("Loading: Loading menu...")

        menuService.getMenu(menuID: menuID) { [weak self] result in
            DispatchQueue.main.async {
                print("Loading dismissed")

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
        guard let menu = completeMenu else { return }

        // Update menu name (using first collection's restaurant or just "Menu")
        menuNameLabel.text = "Menu"

        // Update collections count
        collectionsCountLabel.text = "\(menu.collections.count)"

        // Calculate total products
        let totalProducts = menu.collections.reduce(0) { $0 + $1.products.count }
        productsCountLabel.text = "\(totalProducts)"
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
        print("Loading: Submitting menu...")

        menuService.submitMenu(menuID: menuID) { [weak self] result in
            DispatchQueue.main.async {
                print("Loading dismissed")

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
