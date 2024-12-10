import UIKit
import SnapKit

class CollectionHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.textSecondary
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
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(countLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    func configure(title: String, count: Int = 0) {
        titleLabel.text = title
        countLabel.text = count > 0 ? "(\(count))" : nil
    }
} 