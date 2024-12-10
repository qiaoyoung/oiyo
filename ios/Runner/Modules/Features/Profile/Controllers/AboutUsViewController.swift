import UIKit
import SnapKit

class AboutUsViewController: UIViewController {
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "app_icon")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Planet Station"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = ColorManager.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "Version \(version)"
        }
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var contactStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email: Oiyo2024@oiyo.com"
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "About Us"
        view.backgroundColor = .systemBackground
        setupCustomBackButton()
        
        view.addSubview(iconImageView)
        view.addSubview(appNameLabel)
        view.addSubview(versionLabel)
        view.addSubview(contactStackView)
        
        contactStackView.addArrangedSubview(emailLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        contactStackView.snp.makeConstraints { make in
            make.top.equalTo(versionLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
    }
} 
