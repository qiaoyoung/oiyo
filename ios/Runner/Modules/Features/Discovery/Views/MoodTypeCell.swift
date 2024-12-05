import UIKit

class MoodTypeCell: UICollectionViewCell {
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [iconLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configure(type: MoodPostModel.MoodType, title: String, isSelected: Bool) {
        titleLabel.text = title
        
        // 设置表情
        switch type {
        case .happy: iconLabel.text = "😊"
        case .excited: iconLabel.text = "🤩"
        case .peaceful: iconLabel.text = "😌"
        case .sad: iconLabel.text = "😢"
        case .angry: iconLabel.text = "😠"
        case .anxious: iconLabel.text = "😰"
        }
        
        // 设置选中状态
        if isSelected {
            contentView.backgroundColor = ColorManager.secondary.withAlphaComponent(0.3)
            contentView.layer.cornerRadius = 8
        } else {
            contentView.backgroundColor = .clear
        }
    }
} 