import Foundation
import UIKit

protocol ProfileHeaderCellDelegate: AnyObject {
    func profileHeaderCellDidTapAvatar(_ cell: ProfileHeaderCell)
    func profileHeaderCellDidTapNickname(_ cell: ProfileHeaderCell)
}

class ProfileHeaderCell: UITableViewCell {
    
    weak var delegate: ProfileHeaderCellDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        iv.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap))
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = ColorManager.textPrimary
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNicknameTap))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    private let levelView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.primary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.primary
        label.text = "Lv.0"
        return label
    }()
    
    private let signatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.textSecondary
        label.text = "点击登录，开启AI之旅"
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorManager.textSecondary
        iv.image = UIImage(systemName: "chevron.right")
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nicknameLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with user: UserModel) {
        // 使用 UserDataManager 中的用户信息
        if let currentUser = UserDataManager.shared.currentUser {
            // 设置头像
            if let avatarData = currentUser.avatarData,
               let image = UIImage(data: avatarData) {
                avatarImageView.image = image
            } else {
                // 使用默认头像
                avatarImageView.image = UIImage(systemName: "person.circle.fill")
                avatarImageView.tintColor = ColorManager.primary
            }
            
            // 设置昵称
            nicknameLabel.text = currentUser.nickname
        }
    }
    
    @objc private func handleAvatarTap() {
        delegate?.profileHeaderCellDidTapAvatar(self)
    }
    
    @objc private func handleNicknameTap() {
        delegate?.profileHeaderCellDidTapNickname(self)
    }
} 
