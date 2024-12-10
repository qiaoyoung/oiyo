import UIKit
import SnapKit

class PortalViewController: UIViewController {
    
    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "app_icon")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Planet Station"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = ColorManager.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your AI Assistant Platform"
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var agreementCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = ColorManager.primary
        button.addTarget(self, action: #selector(handleCheckboxTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.text = "I have read and agree to the "
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private lazy var agreementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms of Service", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(ColorManager.primary, for: .normal)
        button.addTarget(self, action: #selector(handleAgreementTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var entryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Journey", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = ColorManager.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleEntry), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(agreementCheckbox)
        view.addSubview(agreementLabel)
        view.addSubview(agreementButton)
        view.addSubview(entryButton)
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.width.height.equalTo(120)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        agreementCheckbox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(entryButton.snp.top).offset(-20)
            make.size.equalTo(24)
        }
        
        agreementLabel.snp.makeConstraints { make in
            make.leading.equalTo(agreementCheckbox.snp.trailing).offset(8)
            make.centerY.equalTo(agreementCheckbox)
        }
        
        agreementButton.snp.makeConstraints { make in
            make.leading.equalTo(agreementLabel.snp.trailing)
            make.centerY.equalTo(agreementCheckbox)
        }
        
        entryButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(44)
        }
    }
    
    @objc private func handleCheckboxTap() {
        agreementCheckbox.isSelected.toggle()
        entryButton.isEnabled = agreementCheckbox.isSelected
        entryButton.alpha = agreementCheckbox.isSelected ? 1.0 : 0.5
    }
    
    @objc private func handleAgreementTap() {
        let webVC = WebViewController(url: "https://sites.google.com/view/oiyo2024/home", title: "Terms of Service")
        let nav = UINavigationController(rootViewController: webVC)
        present(nav, animated: true)
    }
    
    @objc private func handleEntry() {
        guard agreementCheckbox.isSelected else {
            let alert = UIAlertController(
                title: "Agreement Required",
                message: "Please read and agree to the Terms of Service to continue",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        if let user = UserDataManager.shared.currentUser {
            let mainVC = MainTabBarController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
        }
    }
} 
