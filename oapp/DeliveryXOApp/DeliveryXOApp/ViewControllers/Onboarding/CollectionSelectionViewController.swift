//
//  CollectionSelectionViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit
import SVProgressHUD

/// Step 3/5: Collection Selection - Selects menu collections/categories
class CollectionSelectionViewController: UIViewController {

    // MARK: - Properties

    /// The location ID passed from previous screen
    private var locationID: String!

    /// Collection view for displaying collection grid
    private var collectionView: UICollectionView!

    /// Submit button
    private var submitButton: UIButton!

    /// Set of selected collections
    private var selectedCollections: Set<CollectionName> = []

    /// All available collections
    private let allCollections = CollectionName.allCases

    /// Menu service for API calls
    private let menuService = MenuService.shared

    /// Created menu ID
    private var menuID: String?

    // MARK: - Configuration

    /// Configures the view controller with location ID
    /// - Parameter locationID: The ID of the location
    func configure(locationID: String) {
        self.locationID = locationID
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Collections (3/5)"
        view.backgroundColor = .systemBackground

        setupUI()
    }

    // MARK: - UI Setup

    /// Sets up the user interface
    private func setupUI() {
        // TODO: Implement UI layout using Auto Layout or Storyboard
        // - Create UICollectionView with grid layout (2 columns)
        // - Add header label with instructions "Select the categories you want"
        // - Add selection counter label "X of 10 selected"
        // - Add submit button with title "Continue"
        // - Configure collection view delegate and data source
        // - Register custom cell for collection items
        // - Style selected/unselected states
        // - Set minimum 1 collection required

        setupCollectionView()
    }

    /// Sets up collection view
    private func setupCollectionView() {
        // TODO: Implement collection view layout
        // - Use UICollectionViewFlowLayout
        // - Set item size for grid display
        // - Configure spacing and insets
        // - Register cell class
    }

    // MARK: - Validation

    /// Validates that at least one collection is selected
    /// - Returns: True if form is valid, false otherwise
    private func validateSelection() -> Bool {
        if selectedCollections.isEmpty {
            showAlert(
                title: "Selection Required",
                message: "Please select at least one collection"
            )
            return false
        }

        return true
    }

    // MARK: - Actions

    /// Handles submit button tap
    @objc private func submitButtonTapped() {
        guard validateSelection() else { return }
        createDraftMenuAndCollections()
    }

    // MARK: - API Integration

    /// Creates draft menu and then batch creates collections
    private func createDraftMenuAndCollections() {
        SVProgressHUD.show(withStatus: "Creating menu...")

        menuService.createDraftMenu(locationID: locationID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let menu):
                    self?.menuID = menu.id
                    self?.createCollections(menuID: menu.id)

                case .failure(let error):
                    SVProgressHUD.dismiss()
                    self?.showAlert(
                        title: "Error",
                        message: "Failed to create menu: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Batch creates selected collections
    /// - Parameter menuID: The ID of the created menu
    private func createCollections(menuID: String) {
        SVProgressHUD.setStatus("Creating collections...")

        let sortedCollections = selectedCollections.sorted { $0.rawValue < $1.rawValue }
        var completedCount = 0
        var hasError = false

        for (index, collectionName) in sortedCollections.enumerated() {
            let request = CreateCollectionRequest(
                name: collectionName,
                description: nil,
                displayOrder: index,
                isActive: true
            )

            menuService.createCollection(menuID: menuID, request: request) { [weak self] result in
                DispatchQueue.main.async {
                    completedCount += 1

                    switch result {
                    case .success:
                        // Collection created successfully
                        break

                    case .failure(let error):
                        if !hasError {
                            hasError = true
                            self?.showAlert(
                                title: "Warning",
                                message: "Failed to create collection '\(collectionName.rawValue)': \(error.localizedDescription)"
                            )
                        }
                    }

                    // Check if all collections have been processed
                    if completedCount == sortedCollections.count {
                        SVProgressHUD.dismiss()
                        self?.navigateToProductCreation(
                            locationID: self?.locationID ?? "",
                            menuID: menuID
                        )
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    /// Navigates to Product Creation screen
    /// - Parameters:
    ///   - locationID: The location ID
    ///   - menuID: The menu ID
    private func navigateToProductCreation(locationID: String, menuID: String) {
        let productCreationVC = ProductCreationViewController()
        productCreationVC.configure(locationID: locationID, menuID: menuID)
        navigationController?.pushViewController(productCreationVC, animated: true)
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

    /// Updates the selection counter label
    private func updateSelectionCounter() {
        // TODO: Update UI label showing "X of 10 selected"
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCollections.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        // TODO: Implement custom collection cell
        // - Show collection name
        // - Show icon or image for collection
        // - Apply selected/unselected styling
        // - Add checkmark or border for selected state

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CollectionCell",
            for: indexPath
        )

        let collection = allCollections[indexPath.item]
        let isSelected = selectedCollections.contains(collection)

        // Basic styling
        cell.backgroundColor = isSelected ? .systemBlue : .systemGray6
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = isSelected ? 2 : 0
        cell.layer.borderColor = UIColor.systemBlue.cgColor

        // TODO: Add label to cell showing collection.rawValue

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionSelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = allCollections[indexPath.item]

        // Toggle selection
        if selectedCollections.contains(collection) {
            selectedCollections.remove(collection)
        } else {
            selectedCollections.insert(collection)
        }

        // Update UI
        collectionView.reloadItems(at: [indexPath])
        updateSelectionCounter()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // TODO: Calculate appropriate cell size for grid layout
        // - Account for spacing and insets
        // - Make cells square or appropriate aspect ratio

        let width = (collectionView.bounds.width - 48) / 2 // 2 columns with spacing
        return CGSize(width: width, height: width * 0.8)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
