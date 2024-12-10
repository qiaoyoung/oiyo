import UIKit
import StoreKit
import SnapKit

class VIPPackagesViewController: UIViewController {
    
    private let vipPackages: [APPSunManager.ProductID] = [
        .vipWeekly,
        .vipMonthly
    ]
    
    private var selectedPackage: APPSunManager.ProductID?
    
    private var hasAgreedToTerms: Bool = false {
        didSet {
            subscribeButton.isEnabled = hasAgreedToTerms
            subscribeButton.backgroundColor = hasAgreedToTerms ? 
                ColorManager.primary : 
                ColorManager.primary.withAlphaComponent(0.3)
        }
    }
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(VIPPackageCell.self, forCellWithReuseIdentifier: VIPPackageCell.reuseId)
        cv.register(VIPBenefitCell.self, forCellWithReuseIdentifier: VIPBenefitCell.reuseId)
        return cv
    }()
    
    private lazy var subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorManager.primary
        button.setTitle("Subscribe Now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleSubscribe), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = ColorManager.primary
        button.addTarget(self, action: #selector(handleCheckboxTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var topRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    private lazy var termsPrefix: UILabel = {
        let label = UILabel()
        label.text = "I have read and agree to"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var autoRenewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Auto-Renewal Agreement", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(ColorManager.primary, for: .normal)
        button.addTarget(self, action: #selector(handleAutoRenewTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var eulaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms of Service", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(ColorManager.primary, for: .normal)
        button.addTarget(self, action: #selector(handleEULATapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCustomBackButton()
        setupRestoreButton()
        
        // 默认选中月卡
        selectedPackage = .vipMonthly
        
        // 延迟一帧执行，确保 collectionView 已经完成布局
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 创建月卡对应的 IndexPath
            if let monthlyIndex = self.vipPackages.firstIndex(of: .vipMonthly) {
                let indexPath = IndexPath(item: monthlyIndex, section: 0)
                
                // 选中月卡并滚动到对应位置
                self.collectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: []
                )
                
                // 确保 cell 显示正确的选中状态
                if let cell = self.collectionView.cellForItem(at: indexPath) as? VIPPackageCell {
                    cell.isSelected = true
                }
                
                // 刷新权益列表
                self.collectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "VIP Subscription"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(collectionView)
        view.addSubview(subscribeButton)
        
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(subscribeButton.snp.top).offset(-20)
        }
        
        subscribeButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(50)
        }
        
        // 修改协议相关的 UI 布局
        view.addSubview(termsStackView)
        termsStackView.addArrangedSubview(checkboxButton)
        termsStackView.addArrangedSubview(termsContainer)
        
        // 添加第一行
        termsContainer.addArrangedSubview(topRow)
        topRow.addArrangedSubview(termsPrefix)
        topRow.addArrangedSubview(autoRenewButton)
        
        // 添加第二行
        termsContainer.addArrangedSubview(eulaButton)
        
        termsStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(subscribeButton.snp.top).offset(-12)
        }
        
        checkboxButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        // 初始状态下禁用订阅按钮
        hasAgreedToTerms = false
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, _ in
            switch section {
            case 0: // 套餐选择区域
                return self.createPackagesSection()
            case 1: // 权益展示区域
                return self.createBenefitsSection()
            default:
                return nil
            }
        }
        return layout
    }
    
    private func createPackagesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        return section
    }
    
    private func createBenefitsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        section.interGroupSpacing = 8
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(10)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func setupRestoreButton() {
        let restoreButton = UIBarButtonItem(
            title: "Restore",
            style: .plain,
            target: self,
            action: #selector(handleRestore)
        )
        restoreButton.tintColor = ColorManager.primary
        navigationItem.rightBarButtonItem = restoreButton
    }
    
    // MARK: - Actions
    @objc private func handleCheckboxTapped() {
        checkboxButton.isSelected.toggle()
        hasAgreedToTerms = checkboxButton.isSelected
    }
    
    @objc private func handleAutoRenewTapped() {
        showAutoRenewTerms()
    }
    
    @objc private func handleEULATapped() {
        showEULA()
    }
    
    @objc private func handleRestore() {
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.restorePurchases { [weak self] success, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        self?.showSuccessAlert(message: "Purchases restored successfully!")
                        // 恢复成功后刷新用户状态
                        if UserDataManager.shared.isVIPActive {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self?.showErrorAlert(message: error?.localizedDescription ?? "Failed to restore purchases")
                    }
                }
            }
        }
    }
    
    private func showAutoRenewTerms() {
        let vc = TermsViewController(type: .autoRenew)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showEULA() {
        let eulaURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        let webVC = WebViewController(url: eulaURL, title: "Terms of Service")
        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension VIPPackagesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return vipPackages.count
        case 1:
            if let selectedPackage = selectedPackage {
                return VIPBenefitModel.benefits(for: selectedPackage).count
            }
            return 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: VIPPackageCell.reuseId,
                for: indexPath
            ) as! VIPPackageCell
            
            let package = vipPackages[indexPath.item]
            cell.configure(with: package, isPopular: package == .vipMonthly)
            cell.isSelected = package == selectedPackage
            
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: VIPBenefitCell.reuseId,
                for: indexPath
            ) as! VIPBenefitCell
            
            if let selectedPackage = selectedPackage {
                let benefits = VIPBenefitModel.benefits(for: selectedPackage)
                cell.configure(with: benefits[indexPath.item])
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension VIPPackagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 只处理套餐选择区域的点击事件
        if indexPath.section == 0 {
            let previousPackage = selectedPackage
            selectedPackage = vipPackages[indexPath.item]
            
            // 如果有之前选中的项，找到它的索引并取消选中
            if let previous = previousPackage,
               let previousIndex = vipPackages.firstIndex(of: previous) {
                let previousIndexPath = IndexPath(item: previousIndex, section: 0)
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? VIPPackageCell {
                    previousCell.isSelected = false
                }
            }
            
            // 设置新选中项的状态
            if let cell = collectionView.cellForItem(at: indexPath) as? VIPPackageCell {
                cell.isSelected = true
            }
            
            // 只刷新权益列表部分
            collectionView.reloadSections(IndexSet(integer: 1))
        }
        
        // 如果是权益列表区域，立即取消选中状态
        if indexPath.section == 1 {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    // 禁用权益列表的选中效果
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // 只允许套餐选择区域可以选中
        return indexPath.section == 0
    }
    
    // 处理 cell 的选中状态
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let packageCell = cell as? VIPPackageCell {
                let package = vipPackages[indexPath.item]
                packageCell.isSelected = package == selectedPackage
            }
        }
    }
}

// MARK: - Purchase Handling
extension VIPPackagesViewController {
    @objc private func handleSubscribe() {
        guard hasAgreedToTerms else {
            showErrorAlert(message: "Please agree to the terms first")
            return
        }
        
        guard let package = selectedPackage else {
            showErrorAlert(message: "Please select a subscription plan")
            return
        }
        
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.fetchProducts(productIds: [package]) { [weak self] products, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let product = products?.first {
                        self?.showSubscriptionConfirmation(for: product, package: package)
                    } else {
                        self?.showErrorAlert(message: "获取商品信息失败，请稍后重试")
                    }
                }
            }
        }
    }
}

// MARK: - Alert Helpers
private extension VIPPackagesViewController {
    func showLoadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Processing...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true)
        return alert
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Notice",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSubscriptionConfirmation(for product: SKProduct, package: APPSunManager.ProductID) {
        let benefits = VIPBenefitModel.benefits(for: package)
        let benefitsText = benefits.map { "• \($0.title)" }.joined(separator: "\n")
        
        let alert = UIAlertController(
            title: "Confirm Subscription",
            message: """
                Subscribe to \(package.title)
                Price: $\(package.price)
                Duration: \(package.subscriptionDays) days
                
                Member Benefits:
                \(benefitsText)
                """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default) { [weak self] _ in
            self?.handlePurchase(product)
        })
        
        present(alert, animated: true)
    }
    
    func handlePurchase(_ product: SKProduct) {
        let loadingAlert = showLoadingAlert()
        
        APPSunManager.shared.purchase(product: product) { [weak self] success, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if success {
                        self?.showSuccessAlert(message: "Subscription successful!")
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.showErrorAlert(message: error?.localizedDescription ?? "Subscription failed, please try again later")
                    }
                }
            }
        }
    }
} 
