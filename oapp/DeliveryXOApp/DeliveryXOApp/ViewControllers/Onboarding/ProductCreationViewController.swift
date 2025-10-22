//
//  ProductCreationViewController.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import UIKit

/// Step 4/5: Product Creation - Creates products and adds them to menu
class ProductCreationViewController: UIViewController {

    // MARK: - Properties

    /// The location ID passed from previous screen
    private var locationID: String!

    /// The menu ID passed from previous screen
    private var menuID: String!

    /// Text field for product name
    private var nameTextField: UITextField!

    /// Text view for product description
    private var descriptionTextView: UITextView!

    /// Text field for price
    private var priceTextField: UITextField!

    /// Picker view for category/collection selection
    private var categoryPickerView: UIPickerView!

    /// Button to upload product photo
    private var uploadPhotoButton: UIButton!

    /// Image view to display selected photo
    private var photoImageView: UIImageView!

    /// Add Sample button (for quick testing)
    private var addSampleButton: UIButton!

    /// Add Product button
    private var addProductButton: UIButton!

    /// Finish button
    private var finishButton: UIButton!

    /// Table view showing added products
    private var productsTableView: UITableView!

    /// Selected product photo
    private var selectedProductPhoto: UIImage?

    /// Uploaded photo URL from S3
    private var uploadedPhotoURL: String?

    /// Selected category/collection
    private var selectedCollectionName: CollectionName?

    /// Available collections (loaded from menu)
    private var availableCollections: [CollectionWithProducts] = []

    /// List of added products
    private var addedProducts: [(product: Product, collection: CollectionName)] = []

    /// Menu service for API calls
    private let menuService = MenuService.shared

    /// Media service for image uploads
    private let mediaService = MediaService.shared

    // MARK: - Configuration

    /// Configures the view controller with location and menu IDs
    /// - Parameters:
    ///   - locationID: The ID of the location
    ///   - menuID: The ID of the menu
    func configure(locationID: String, menuID: String) {
        self.locationID = locationID
        self.menuID = menuID
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Products (4/5)"
        view.backgroundColor = .systemBackground

        setupUI()
        loadAvailableCollections()
    }

    // MARK: - UI Setup

    /// Sets up the user interface
    private func setupUI() {
        // Scroll view for form
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Name text field
        nameTextField = UITextField()
        nameTextField.placeholder = "Product Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameTextField)

        // Description text view
        descriptionTextView = UITextView()
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.text = "Description (optional)"
        descriptionTextView.textColor = .placeholderText
        descriptionTextView.delegate = self
        contentView.addSubview(descriptionTextView)

        // Price text field
        priceTextField = UITextField()
        priceTextField.placeholder = "Price"
        priceTextField.borderStyle = .roundedRect
        priceTextField.keyboardType = .decimalPad
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceTextField)

        // Category picker
        categoryPickerView = UIPickerView()
        categoryPickerView.translatesAutoresizingMaskIntoConstraints = false
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        contentView.addSubview(categoryPickerView)

        // Photo upload button
        uploadPhotoButton = UIButton(type: .system)
        uploadPhotoButton.setTitle("Upload Photo (optional)", for: .normal)
        uploadPhotoButton.backgroundColor = .systemGray6
        uploadPhotoButton.layer.cornerRadius = 8
        uploadPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoButtonTapped), for: .touchUpInside)
        contentView.addSubview(uploadPhotoButton)

        // Photo image view
        photoImageView = UIImageView()
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 8
        photoImageView.backgroundColor = .systemGray6
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoImageView)

        // Add Sample button
        addSampleButton = UIButton(type: .system)
        addSampleButton.setTitle("Add Sample", for: .normal)
        addSampleButton.backgroundColor = .systemGray5
        addSampleButton.setTitleColor(.label, for: .normal)
        addSampleButton.layer.cornerRadius = 8
        addSampleButton.translatesAutoresizingMaskIntoConstraints = false
        addSampleButton.addTarget(self, action: #selector(addSampleButtonTapped), for: .touchUpInside)
        contentView.addSubview(addSampleButton)

        // Add Product button
        addProductButton = UIButton(type: .system)
        addProductButton.setTitle("Add Product", for: .normal)
        addProductButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        addProductButton.backgroundColor = .systemBlue
        addProductButton.setTitleColor(.white, for: .normal)
        addProductButton.layer.cornerRadius = 12
        addProductButton.translatesAutoresizingMaskIntoConstraints = false
        addProductButton.addTarget(self, action: #selector(addProductButtonTapped), for: .touchUpInside)
        contentView.addSubview(addProductButton)

        // Products table view
        productsTableView = UITableView()
        productsTableView.translatesAutoresizingMaskIntoConstraints = false
        productsTableView.delegate = self
        productsTableView.dataSource = self
        contentView.addSubview(productsTableView)

        // Finish button
        finishButton = UIButton(type: .system)
        finishButton.setTitle("Finish Adding Products", for: .normal)
        finishButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        finishButton.backgroundColor = .systemGreen
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.layer.cornerRadius = 12
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        view.addSubview(finishButton)

        // Layout constraints
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -16),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Name field
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            // Description text view
            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 80),

            // Price field
            priceTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            priceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            priceTextField.heightAnchor.constraint(equalToConstant: 44),

            // Category picker
            categoryPickerView.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 16),
            categoryPickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryPickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryPickerView.heightAnchor.constraint(equalToConstant: 120),

            // Photo upload button
            uploadPhotoButton.topAnchor.constraint(equalTo: categoryPickerView.bottomAnchor, constant: 16),
            uploadPhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uploadPhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            uploadPhotoButton.heightAnchor.constraint(equalToConstant: 44),

            // Photo image view
            photoImageView.topAnchor.constraint(equalTo: uploadPhotoButton.bottomAnchor, constant: 16),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 120),
            photoImageView.heightAnchor.constraint(equalToConstant: 120),

            // Add Sample button
            addSampleButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
            addSampleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addSampleButton.widthAnchor.constraint(equalToConstant: 120),
            addSampleButton.heightAnchor.constraint(equalToConstant: 44),

            // Add Product button
            addProductButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
            addProductButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addProductButton.leadingAnchor.constraint(equalTo: addSampleButton.trailingAnchor, constant: 16),
            addProductButton.heightAnchor.constraint(equalToConstant: 44),

            // Products table view
            productsTableView.topAnchor.constraint(equalTo: addProductButton.bottomAnchor, constant: 20),
            productsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            productsTableView.heightAnchor.constraint(equalToConstant: 200),
            productsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Finish button
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    /// Loads available collections from menu
    private func loadAvailableCollections() {
        print("Loading: Loading collections...")

        menuService.getMenu(menuID: menuID) { [weak self] result in
            DispatchQueue.main.async {
                print("Loading dismissed")

                switch result {
                case .success(let completeMenu):
                    self?.availableCollections = completeMenu.collections
                    if let firstCollection = completeMenu.collections.first {
                        self?.selectedCollectionName = firstCollection.name
                    }
                    // TODO: Reload category picker

                case .failure(let error):
                    self?.showAlert(
                        title: "Error",
                        message: "Failed to load collections: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    // MARK: - Validation

    /// Validates the product form
    /// - Returns: True if form is valid, false otherwise
    private func validateForm() -> Bool {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty else {
            showAlert(title: "Validation Error", message: "Product name is required")
            return false
        }

        guard let priceText = priceTextField.text?.trimmingCharacters(in: .whitespaces),
              let price = Double(priceText),
              price > 0 else {
            showAlert(title: "Validation Error", message: "Valid price is required")
            return false
        }

        guard selectedCollectionName != nil else {
            showAlert(title: "Validation Error", message: "Please select a category")
            return false
        }

        // TODO: Add more validation rules
        // - Validate price range
        // - Validate name length
        // - Validate description length if provided

        return true
    }

    // MARK: - Actions

    /// Handles upload photo button tap
    @objc private func uploadPhotoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    /// Handles add sample product button tap
    @objc private func addSampleButtonTapped() {
        // Pre-fill form with sample data for quick testing
        nameTextField.text = "Sample Product"
        descriptionTextView.text = "A delicious sample product"
        priceTextField.text = "9.99"
        selectedProductPhoto = nil
        uploadedPhotoURL = nil
        photoImageView?.image = nil
    }

    /// Handles add product button tap
    @objc private func addProductButtonTapped() {
        guard validateForm() else { return }

        // If photo is selected, upload it first, then create product
        if let photo = selectedProductPhoto {
            uploadPhotoAndCreateProduct(photo: photo)
        } else {
            createProduct()
        }
    }

    /// Handles finish button tap
    @objc private func finishButtonTapped() {
        if addedProducts.isEmpty {
            showAlert(
                title: "No Products Added",
                message: "Please add at least one product before continuing"
            )
            return
        }

        navigateToReviewSubmit(menuID: menuID)
    }

    // MARK: - API Integration

    /// Uploads product photo and then creates product
    /// - Parameter photo: The product photo to upload
    private func uploadPhotoAndCreateProduct(photo: UIImage) {
        print("Loading: Uploading photo...")

        let fileName = "product-photo-\(UUID().uuidString)"

        mediaService.uploadImage(photo, fileName: fileName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fileURL):
                    self?.uploadedPhotoURL = fileURL
                    self?.createProduct()

                case .failure(let error):
                    print("Loading dismissed")
                    self?.showAlert(
                        title: "Upload Failed",
                        message: "Failed to upload photo: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Creates the product via API
    private func createProduct() {
        print("Loading: Creating product...")

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              let priceText = priceTextField.text?.trimmingCharacters(in: .whitespaces),
              let price = Double(priceText),
              let collectionName = selectedCollectionName else {
            print("Loading dismissed")
            return
        }

        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespaces)

        let request = CreateProductRequest(
            name: name,
            description: description?.isEmpty == false ? description : nil,
            basePrice: price,
            imageUrl: uploadedPhotoURL,
            isActive: true
        )

        menuService.createProduct(locationID: locationID, request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    // Product created, now add to menu
                    self?.addProductToMenu(product: product, collectionName: collectionName)

                case .failure(let error):
                    print("Loading dismissed")
                    self?.showAlert(
                        title: "Error",
                        message: "Failed to create product: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Adds product to menu collection
    /// - Parameters:
    ///   - product: The created product
    ///   - collectionName: The collection to add the product to
    private func addProductToMenu(product: Product, collectionName: CollectionName) {
        print("Loading: Adding to menu...")

        guard let collection = availableCollections.first(where: { $0.name == collectionName }) else {
            print("Loading dismissed")
            showAlert(title: "Error", message: "Collection not found")
            return
        }

        let request = AddProductToMenuRequest(
            productId: product.id,
            displayOrder: nil,
            isAvailable: true
        )

        menuService.addProductToMenu(
            menuID: menuID,
            collectionID: collection.id,
            request: request
        ) { [weak self] result in
            DispatchQueue.main.async {
                print("Loading dismissed")

                switch result {
                case .success:
                    self?.addedProducts.append((product, collectionName))
                    self?.productsTableView?.reloadData()
                    self?.clearForm()
                    self?.showAlert(
                        title: "Success",
                        message: "Product '\(product.name)' added successfully"
                    )

                case .failure(let error):
                    self?.showAlert(
                        title: "Error",
                        message: "Product created but failed to add to menu: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Clears the form after successful product addition
    private func clearForm() {
        nameTextField.text = ""
        descriptionTextView.text = ""
        priceTextField.text = ""
        selectedProductPhoto = nil
        uploadedPhotoURL = nil
        photoImageView?.image = nil
    }

    // MARK: - Navigation

    /// Navigates to Review & Submit screen
    /// - Parameter menuID: The menu ID
    private func navigateToReviewSubmit(menuID: String) {
        let reviewSubmitVC = ReviewSubmitViewController()
        reviewSubmitVC.configure(menuID: menuID)
        navigationController?.pushViewController(reviewSubmitVC, animated: true)
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

extension ProductCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedProductPhoto = editedImage
            photoImageView?.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedProductPhoto = originalImage
            photoImageView?.image = originalImage
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource

extension ProductCreationViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableCollections.count
    }
}

// MARK: - UIPickerViewDelegate

extension ProductCreationViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableCollections[row].name.rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCollectionName = availableCollections[row].name
    }
}

// MARK: - UITableViewDataSource

extension ProductCreationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ProductCell")
        let (product, collection) = addedProducts[indexPath.row]

        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = "\(collection.rawValue) - $\(String(format: "%.2f", product.basePrice))"

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProductCreationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension ProductCreationViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description (optional)"
            textView.textColor = .placeholderText
        }
    }
}
