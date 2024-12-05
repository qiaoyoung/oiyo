import UIKit
import SnapKit

class HistoryCell: UITableViewCell {
    
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
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.primary
        label.backgroundColor = ColorManager.primary.withAlphaComponent(0.1)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.textSecondary
        return label
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
        
        [avatarImageView, nameLabel, typeLabel, timeLabel].forEach {
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
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.top.equalTo(avatarImageView).offset(4)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(8)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.bottom.equalTo(avatarImageView).offset(-4)
        }
    }
    
    func configure(with item: BrowsingHistoryItem) {
        if let image = UIImage(named: item.ai.avatar) {
            avatarImageView.image = image
        }
        nameLabel.text = item.ai.nickname
        typeLabel.text = item.ai.aiType
        timeLabel.text = formatDate(item.timestamp)
    }
    
    private func formatDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let minutes = components.minute {
            if minutes < 60 {
                return "\(minutes) minutes ago"
            }
        }
        
        if let hours = components.hour {
            if hours < 24 {
                return "\(hours) hours ago"
            }
        }
        
        if let days = components.day {
            if days < 30 {
                return "\(days) days ago"
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
} 