import UIKit
import SnapKit

class AIBasicInfoView: UIView {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Basic Information"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let personalityView = InfoItemView(icon: "brain", title: "Personality")
    private let specialtiesView = InfoItemView(icon: "star", title: "Specialties")
    private let languagesView = InfoItemView(icon: "message", title: "Languages")
    
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
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(titleLabel)
        addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(personalityView)
        infoStackView.addArrangedSubview(specialtiesView)
        infoStackView.addArrangedSubview(languagesView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configuration
    func configure(with ai: AIUserModel) {
        personalityView.configure(content: ai.personality)
        specialtiesView.configure(content: ai.specialties.joined(separator: ", "))
        languagesView.configure(content: ai.languages.joined(separator: ", "))
    }
}

// MARK: - InfoItemView
private class InfoItemView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appPrimary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    init(icon: String, title: String) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(contentLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalTo(iconImageView)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(content: String) {
        contentLabel.text = content
    }
} 