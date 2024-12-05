import UIKit
import SnapKit

class ProfileMenuCell: UITableViewCell {
    
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
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = ColorManager.textSecondary
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
        backgroundColor = .white
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(arrowImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImageView.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with item: MenuItem) {
        iconImageView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        arrowImageView.isHidden = !item.showArrow
    }
} 