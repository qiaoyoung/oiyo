import UIKit
import SnapKit

class AIFeaturesView: UIView {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Feature Tags"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let tagFlowLayout = TagFlowLayout()
    
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
        
        addSubview(titleLabel)
        addSubview(tagFlowLayout)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        tagFlowLayout.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16).priority(.low)
        }
    }
    
    // MARK: - Configuration
    func configure(with features: [String]) {
        tagFlowLayout.configure(with: features)
        
        let height = tagFlowLayout.intrinsicContentSize.height + 16 * 3 + titleLabel.intrinsicContentSize.height
        frame.size.height = height
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        let height = tagFlowLayout.intrinsicContentSize.height + 16 * 3 + titleLabel.intrinsicContentSize.height
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

// MARK: - TagFlowLayout
private class TagFlowLayout: UIView {
    private var tags: [String] = []
    private let spacing: CGFloat = 8
    private var tagViews: [UIView] = []
    
    override var intrinsicContentSize: CGSize {
        let height = calculateContentHeight()
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    func configure(with tags: [String]) {
        // 清除旧的视图和数据
        tagViews.forEach { $0.removeFromSuperview() }
        tagViews.removeAll()
        self.tags = tags
        
        // 立即布局标签
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTags()
    }
    
    private func layoutTags() {
        // 清除旧的视图
        tagViews.forEach { $0.removeFromSuperview() }
        tagViews.removeAll()
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let maxWidth = bounds.width
        
        for tag in tags {
            let tagSize = calculateTagSize(for: tag)
            
            // 检查是否需要换行
            if currentX + tagSize.width > maxWidth {
                currentX = 0
                currentY += tagSize.height + spacing
            }
            
            // 创建并添加标签视图
            let tagView = createTagView(with: tag)
            tagView.frame = CGRect(
                x: currentX,
                y: currentY,
                width: tagSize.width,
                height: tagSize.height
            )
            addSubview(tagView)
            tagViews.append(tagView)
            
            currentX += tagSize.width + spacing
        }
        
        // 更新视图高度
        let finalHeight = currentY + (tags.isEmpty ? 0 : 28)
        frame.size.height = finalHeight
        invalidateIntrinsicContentSize()
    }
    
    private func calculateTagSize(for text: String) -> CGSize {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        
        let textSize = (text as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 28),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 14)],
            context: nil
        ).size
        
        return CGSize(
            width: ceil(textSize.width) + 24,
            height: 28
        )
    }
    
    private func calculateContentHeight() -> CGFloat {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let maxWidth = bounds.width
        
        for tag in tags {
            let tagSize = calculateTagSize(for: tag)
            
            if currentX + tagSize.width > maxWidth {
                currentX = 0
                currentY += tagSize.height + spacing
            }
            
            currentX += tagSize.width + spacing
        }
        
        return currentY + (tags.isEmpty ? 0 : 28)
    }
    
    private func createTagView(with text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .appPrimary.withAlphaComponent(0.1)
        container.layer.cornerRadius = 14
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .appPrimary
        
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }
        
        return container
    }
} 
