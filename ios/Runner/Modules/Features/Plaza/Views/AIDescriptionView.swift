import UIKit
import SnapKit

class AIDescriptionView: UIView {
    
    // MARK: - UI Components
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let quoteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "quote.bubble")
        imageView.tintColor = .appPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(quoteImageView)
        addSubview(descriptionLabel)
        
        quoteImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.size.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(quoteImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configuration
    func configure(with description: String) {
        descriptionLabel.text = description
    }
} 
