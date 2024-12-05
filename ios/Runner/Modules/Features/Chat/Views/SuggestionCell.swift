import UIKit
import SnapKit

class SuggestionCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.primary
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
        backgroundColor = ColorManager.primary.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
} 