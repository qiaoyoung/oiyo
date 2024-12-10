import UIKit
import SnapKit

class CategoryHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View All", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    var onMoreButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(moreButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }
    
    @objc private func moreButtonTapped() {
        onMoreButtonTapped?()
    }
    
    func configure(with title: String, onMoreButtonTapped: (() -> Void)? = nil) {
        titleLabel.text = title
        self.onMoreButtonTapped = onMoreButtonTapped
    }
} 