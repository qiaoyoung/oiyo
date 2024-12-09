import UIKit
import StoreKit

class CoinsPackagesViewController: UIViewController {
    
    private let coinPackages: [APPSunManager.ProductID] = [
        .oiyo2, .oiyo5, .oiyo9, .oiyo19,
        .oiyo49, .oiyo99, .oiyo159, .oiyo239
    ]
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var headerIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "dollarsign.circle.fill")
        iv.tintColor = .systemOrange
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var balanceTitle: UILabel = {
        let label = UILabel()
        label.text = "Current Balance"
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = ColorManager.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.register(CoinPackageCell.self, forCellReuseIdentifier: "CoinPackageCell")
        tv.separatorStyle = .none
        tv.backgroundColor = .systemGroupedBackground
        tv.isScrollEnabled = true
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCustomBackButton()
        updateBalance()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Restore",
            style: .plain,
            target: self,
            action: #selector(handleRestore)
        )
    }
    
    private func setupUI() {
        title = "Purchase Coins"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(headerView)
        headerView.addSubview(headerIcon)
        headerView.addSubview(balanceTitle)
        headerView.addSubview(balanceLabel)
        view.addSubview(tableView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }
        
        headerIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(48)
        }
        
        balanceTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerIcon.snp.bottom).offset(16)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(balanceTitle.snp.bottom).offset(8)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        backButton.tintColor = ColorManager.textPrimary
        navigationItem.leftBarButtonItem = backButton
        navigationItem.backButtonTitle = ""
    }
    
    private func updateBalance() {
        balanceLabel.text = "\(UserDataManager.shared.coinsBalance) Coins"
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleRestore() {
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.restorePurchases { [weak self] success, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        self?.showSuccessAlert(message: "Purchases restored successfully")
                        self?.updateBalance()
                    } else {
                        self?.showErrorAlert(message: error?.localizedDescription ?? "Failed to restore purchases")
                    }
                }
            }
        }
    }
}

extension CoinsPackagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinPackages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinPackageCell", for: indexPath) as! CoinPackageCell
        let package = coinPackages[indexPath.row]
        
        cell.configure(
            coins: package.coins,
            price: "\(package.price)"
        )
        
        return cell
    }
}

extension CoinsPackagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let package = coinPackages[indexPath.row]
        
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.fetchProducts(productIds: [package]) { [weak self] products, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    guard let self = self else { return }
                    
                    if let products = products,
                       let product = products.first {
                        self.showPurchaseConfirmation(for: product, package: package)
                    } else {
                        self.showErrorAlert(message: "This product is currently unavailable")
                    }
                }
            }
        }
    }
    
    private func showPurchaseConfirmation(for product: SKProduct, package: APPSunManager.ProductID) {
        let alert = UIAlertController(
            title: "Purchase Coins",
            message: "Would you like to purchase \(package.coins) coins for \(APPSunManager.shared.formattedPrice(for: product))?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Purchase", style: .default) { [weak self] _ in
            self?.handlePurchase(product)
        })
        
        present(alert, animated: true)
    }
    
    private func handlePurchase(_ product: SKProduct) {
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.purchase(product: product) { [weak self] success, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        self?.showSuccessAlert(message: "Purchase successful!")
                        self?.updateBalance()
                    } else {
                        self?.showErrorAlert(message: error?.localizedDescription ?? "Purchase failed")
                    }
                }
            }
        }
    }
}

// MARK: - Alert Helpers
extension CoinsPackagesViewController {
    private func showLoadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Processing...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true)
        return alert
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
