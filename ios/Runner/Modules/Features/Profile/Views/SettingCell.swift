import UIKit
import SnapKit

class SettingCell: UITableViewCell {
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorManager.primary
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = ColorManager.primary
        return toggle
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray3
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
        [iconImageView, titleLabel, detailLabel, toggleSwitch, arrowImageView].forEach {
            contentView.addSubview($0)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        toggleSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func configure(with item: SettingItem) {
        iconImageView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        detailLabel.text = item.detail
        
        switch item.type {
        case .normal:
            toggleSwitch.isHidden = true
            arrowImageView.isHidden = true
        case .toggle:
            toggleSwitch.isHidden = false
            arrowImageView.isHidden = true
        case .arrow:
            toggleSwitch.isHidden = true
            arrowImageView.isHidden = false
        }
    }
} 