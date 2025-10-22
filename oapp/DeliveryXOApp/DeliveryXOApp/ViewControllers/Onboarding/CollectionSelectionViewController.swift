//
//  CollectionSelectionViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit

/// Step 3/5: Collection Selection - Selects menu collections/categories
class CollectionSelectionViewController: UIViewController {

    // MARK: - Properties

    /// The location ID passed from previous screen
    private var locationID: String!

    /// Collection view for displaying collection grid
    private var collectionView: UICollectionView!

    /// Submit button
    private var submitButton: UIButton!

    /// Header label with instructions
    private var headerLabel: UILabel!

    /// Selection counter label
    private var counterLabel: UILabel!

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
        // Header label
        headerLabel = UILabel()
        headerLabel.text = "Select the categories you want"
        headerLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        // Counter label
        counterLabel = UILabel()
        counterLabel.text = "0 of \(allCollections.count) selected"
        counterLabel.font = .systemFont(ofSize: 16, weight: .regular)
        counterLabel.textColor = .secondaryLabel
        counterLabel.textAlignment = .center
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(counterLabel)

        // Setup collection view
        setupCollectionView()
        view.addSubview(collectionView)

        // Submit button
        submitButton = UIButton(type: .system)
        submitButton.setTitle("Continue", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 12
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)

        // Layout constraints
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Header label
            headerLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Counter label
            counterLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            counterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            counterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Collection view
            collectionView.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),

            // Submit button
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    /// Sets up collection view
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
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
        print("Loading: Creating menu...")

        menuService.createDraftMenu(locationID: locationID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let menu):
                    self?.menuID = menu.id
                    self?.createCollections(menuID: menu.id)

                case .failure(let error):
                    print("Loading dismissed")
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
        print("Loading: Creating collections...")

        let sortedCollections = selectedCollections.sorted { $0.rawValue < $1.rawValue }
        var completedCount = 0
        var hasError = false

        for (index, collectionName) in sortedCollections.enumerated() {
            let request = CreateCollectionRequest(
                name: collectionName,
                position: index,
                imageUrl: nil
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
                        print("Loading dismissed")
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
        counterLabel.text = "\(selectedCollections.count) of \(allCollections.count) selected"
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CollectionCell",
            for: indexPath
        ) as? CollectionCell else {
            return UICollectionViewCell()
        }

        let collection = allCollections[indexPath.item]
        let isSelected = selectedCollections.contains(collection)

        cell.configure(with: collection, isSelected: isSelected)

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

// MARK: - CollectionCell

/// Custom collection view cell for displaying collection categories
class CollectionCell: UICollectionViewCell {

    // MARK: - Properties

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(checkmarkImageView)

        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2

        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            checkmarkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    // MARK: - Configuration

    /// Configures the cell with collection data
    /// - Parameters:
    ///   - collection: The collection to display
    ///   - isSelected: Whether the collection is selected
    func configure(with collection: CollectionName, isSelected: Bool) {
        nameLabel.text = collection.rawValue

        if isSelected {
            contentView.backgroundColor = .systemBlue
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
            nameLabel.textColor = .white
            checkmarkImageView.isHidden = false
        } else {
            contentView.backgroundColor = .systemGray6
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            nameLabel.textColor = .label
            checkmarkImageView.isHidden = true
        }
    }
}
