import UIKit
import SnapKit

class ChatListCell: UITableViewCell {
    
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
        iv.layer.cornerRadius = 25
        iv.backgroundColor = ColorManager.secondary.withAlphaComponent(0.3)
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.textSecondary
        label.numberOfLines = 1
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let pinnedImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pin.fill")
        iv.tintColor = ColorManager.primary
        iv.isHidden = true
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
        
        [avatarImageView, nameLabel, lastMessageLabel, timeLabel].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-12)
            make.left.greaterThanOrEqualTo(nameLabel.snp.right).offset(8)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-12)
        }
        
        containerView.addSubview(pinnedImageView)
        
        pinnedImageView.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.right.equalTo(timeLabel.snp.left).offset(-8)
            make.width.height.equalTo(12)
        }
    }
    
    func configure(with chatItem: ChatItem) {
        if let image = UIImage(named: chatItem.ai.avatar) {
            avatarImageView.image = image
        }
        nameLabel.text = chatItem.ai.nickname
        lastMessageLabel.text = chatItem.lastMessage
        timeLabel.text = formatDate(chatItem.timestamp)
        pinnedImageView.isHidden = !chatItem.isPinned
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
        
        if let days = components.day {
            if days == 0 {
                // 今天，显示时:分
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            } else if days == 1 {
                // 昨天
                return "昨天"
            } else if days < 7 {
                // 一周内，显示周几
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                return formatter.string(from: date)
            } else {
                // 超过一周，显示年月日
                let formatter = DateFormatter()
                if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
                    formatter.dateFormat = "MM-dd"
                } else {
                    formatter.dateFormat = "yyyy-MM-dd"
                }
                return formatter.string(from: date)
            }
        }
        
        return ""
    }
} 
