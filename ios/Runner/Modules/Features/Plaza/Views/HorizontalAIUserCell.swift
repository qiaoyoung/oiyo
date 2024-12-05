import UIKit
import SnapKit

class HorizontalAIUserCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let signatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
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
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(signatureLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        signatureLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
        }
    }
    
    // MARK: - Configuration
    func configure(with user: AIUserModel) {
        nameLabel.text = user.nickname
        signatureLabel.text = user.signature
        
        // 加载本地头像图片并设置图片高度约束
        if let image = UIImage(named: user.avatar) {
            avatarImageView.image = image
            let ratio = image.size.height / image.size.width
            avatarImageView.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(avatarImageView.snp.width).multipliedBy(ratio)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        avatarImageView.snp.removeConstraints()
        avatarImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
} 