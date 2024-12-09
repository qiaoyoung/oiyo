import UIKit
import StoreKit
import SnapKit

class VIPPackagesViewController: UIViewController {
    
    private let vipPackages: [APPSunManager.ProductID] = [
        .vipWeekly,    // 周卡
        .vipMonthly    // 月卡
    ]
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var headerIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "crown.fill")
        iv.tintColor = .appPrimary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.text = "VIP Benefits"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .appPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var benefitsList: UILabel = {
        let label = UILabel()
        label.attributedText = createBenefitsList()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.register(VIPPackageCell.self, forCellReuseIdentifier: "VIPPackageCell")
        tv.separatorStyle = .none
        tv.backgroundColor = .systemGroupedBackground
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tv
    }()
    
    private func createBenefitsList() -> NSAttributedString {
        let benefits = [
            "Unlimited AI Chat",
            "Priority Response",
            "Advanced Features",
            "No Ads",
            "Exclusive Content"
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let fullText = NSMutableAttributedString()
        
        benefits.forEach { benefit in
            let bulletPoint = NSAttributedString(
                string: "\u{2022} ",
                attributes: [
                    .foregroundColor: UIColor.appPrimary,
                    .font: UIFont.systemFont(ofSize: 16, weight: .bold)
                ]
            )
            
            let benefitText = NSAttributedString(
                string: benefit + "\n",
                attributes: [
                    .foregroundColor: UIColor.label,
                    .font: UIFont.systemFont(ofSize: 16),
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            fullText.append(bulletPoint)
            fullText.append(benefitText)
        }
        
        return fullText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCustomBackButton()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Restore",
            style: .plain,
            target: self,
            action: #selector(handleRestore)
        )
    }
    
    private func setupUI() {
        title = "VIP Subscription"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(headerView)
        headerView.addSubview(headerIcon)
        headerView.addSubview(headerTitle)
        headerView.addSubview(benefitsList)
        view.addSubview(tableView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(300)
        }
        
        headerIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(32)
            make.width.height.equalTo(60)
        }
        
        headerTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerIcon.snp.bottom).offset(24)
        }
        
        benefitsList.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.top.equalTo(headerTitle.snp.bottom).offset(24)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
        navigationItem.backButtonTitle = ""
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
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.showErrorAlert(message: error?.localizedDescription ?? "Failed to restore purchases")
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension VIPPackagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vipPackages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VIPPackageCell", for: indexPath) as! VIPPackageCell
        let package = vipPackages[indexPath.row]
        cell.configure(with: package)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let package = vipPackages[indexPath.row]
        
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.fetchProducts(productIds: [package]) { [weak self] products, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    guard let self = self else { return }
                    
                    if let products = products,
                       let product = products.first {
                        self.showSubscriptionConfirmation(for: product, package: package)
                    } else {
                        self.showErrorAlert(message: "This subscription is currently unavailable")
                    }
                }
            }
        }
    }
}

// MARK: - Alert Helpers
extension VIPPackagesViewController {
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
    
    private func showSubscriptionConfirmation(for product: SKProduct, package: APPSunManager.ProductID) {
        let alert = UIAlertController(
            title: "Subscribe to \(package.title)",
            message: """
                Subscribe for \(APPSunManager.shared.formattedPrice(for: product))
                Duration: \(package.subscriptionDays) days
                
                • Unlimited AI Chat
                • Priority Response
                • Advanced Features
                • No Ads
                • Exclusive Content
                """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default) { [weak self] _ in
            self?.handleSubscription(product)
        })
        
        present(alert, animated: true)
    }
    
    private func handleSubscription(_ product: SKProduct) {
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.purchase(product: product) { [weak self] success, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        self?.showSuccessAlert(message: "Subscription activated successfully!")
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.showErrorAlert(message: error?.localizedDescription ?? "Subscription failed")
                    }
                }
            }
        }
    }
} 
