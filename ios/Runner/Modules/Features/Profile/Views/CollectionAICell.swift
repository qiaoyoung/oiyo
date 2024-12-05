import UIKit
import SnapKit

class CollectionAICell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.backgroundColor = ColorManager.secondary.withAlphaComponent(0.3)
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorManager.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.primary
        label.backgroundColor = ColorManager.primary.withAlphaComponent(0.1)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let ratingView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        
        let starImage = UIImageView(image: UIImage(systemName: "star.fill"))
        starImage.tintColor = ColorManager.primary
        starImage.contentMode = .scaleAspectFit
        starImage.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.textSecondary
        
        stack.addArrangedSubview(starImage)
        stack.addArrangedSubview(label)
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        [avatarImageView, nameLabel, typeLabel, ratingView].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(60)
            make.height.equalTo(20)
        }
        
        ratingView.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        nameLabel.text = nil
        typeLabel.text = nil
        if let ratingLabel = ratingView.arrangedSubviews.last as? UILabel {
            ratingLabel.text = nil
        }
    }
    
    func configure(with ai: AIUserModel) {
        if let image = UIImage(named: ai.avatar) {
            avatarImageView.image = image
        }
        nameLabel.text = ai.nickname
        typeLabel.text = ai.aiType
        
        if let ratingLabel = ratingView.arrangedSubviews.last as? UILabel {
            ratingLabel.text = String(format: "%.1f", ai.rating)
        }
    }
} 