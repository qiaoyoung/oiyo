import UIKit
import SnapKit

class VIPPackageCell: UICollectionViewCell {
    static let reuseId = "VIPPackageCell"
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1.5
        return view
    }()
    
    private lazy var popularTagView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.primary
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private lazy var popularLabel: UILabel = {
        let label = UILabel()
        label.text = "Most Popular"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = ColorManager.primary
        return label
    }()
    
    private lazy var perDayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var checkmarkIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.circle.fill")
        iv.tintColor = ColorManager.primary
        iv.alpha = 0
        return iv
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
        contentView.addSubview(containerView)
        containerView.addSubview(popularTagView)
        popularTagView.addSubview(popularLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(durationLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(perDayLabel)
        containerView.addSubview(checkmarkIcon)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        popularTagView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(100)
        }
        
        popularLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(popularTagView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(durationLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        perDayLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        checkmarkIcon.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8)
            make.width.height.equalTo(20)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            // 更新选中状态的视觉效果
            UIView.animate(withDuration: 0.3, 
                         delay: 0,
                         usingSpringWithDamping: 0.8,
                         initialSpringVelocity: 0.2,
                         options: .curveEaseInOut) {
                if self.isSelected {
                    // 选中状态
                    self.containerView.backgroundColor = ColorManager.primary.withAlphaComponent(0.1)
                    self.containerView.layer.borderColor = ColorManager.primary.cgColor
                    self.containerView.layer.borderWidth = 2
                    self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                    self.containerView.layer.shadowColor = ColorManager.primary.cgColor
                    self.containerView.layer.shadowOpacity = 0.2
                    self.containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
                    self.containerView.layer.shadowRadius = 4
                    self.checkmarkIcon.alpha = 1
                    self.titleLabel.textColor = ColorManager.primary
                } else {
                    // 未选中状态
                    self.containerView.backgroundColor = .systemBackground
                    self.containerView.layer.borderColor = UIColor.systemGray4.cgColor
                    self.containerView.layer.borderWidth = 1
                    self.transform = .identity
                    self.containerView.layer.shadowOpacity = 0
                    self.checkmarkIcon.alpha = 0
                    self.titleLabel.textColor = .label
                }
            }
        }
    }
    
    func configure(with package: APPSunManager.ProductID, isPopular: Bool = false) {
        titleLabel.text = package.title
        durationLabel.text = "\(package.subscriptionDays) Days"
        priceLabel.text = "$\(package.price)"
        
        // 计算每天价格
        let pricePerDay = (Double(package.price) ?? 0) / Double(package.subscriptionDays)
        perDayLabel.text = String(format: "Only $%.2f/day", pricePerDay)
        
        popularTagView.isHidden = !isPopular
        
        // 添加高亮边框效果
        if isPopular {
            containerView.layer.borderWidth = 1.5
            containerView.layer.borderColor = ColorManager.primary.withAlphaComponent(0.3).cgColor
        } else {
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    
    // 添加触摸反馈
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = self.isSelected ? 
                CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = self.isSelected ? 
                CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
        }
    }
} 
