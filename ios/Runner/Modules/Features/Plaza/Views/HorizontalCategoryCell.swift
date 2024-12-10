import UIKit
import SnapKit

protocol HorizontalCategoryCellDelegate: AnyObject {
    func horizontalCategoryCell(_ cell: HorizontalCategoryCell, didSelectUser user: AIUserModel)
}

class HorizontalCategoryCell: UICollectionViewCell {
    
    // MARK: - Properties
    weak var delegate: HorizontalCategoryCellDelegate?
    private var users: [AIUserModel] = []
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = TopAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(HorizontalAIUserCell.self, forCellWithReuseIdentifier: "HorizontalAIUserCell")
        
        // 禁用自动调整内容
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceVertical = false
        
        return collectionView
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
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    func configure(with users: [AIUserModel]) {
        self.users = users
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HorizontalCategoryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 42) / 2 // 考虑边距
        let user = users[indexPath.item]
        
        // 计算图片高度
        let imageHeight: CGFloat
        if let image = UIImage(named: user.avatar) {
            let ratio = image.size.height / image.size.width
            imageHeight = width * ratio
        } else {
            imageHeight = width
        }
        
        // 计算文本高度（减少间距）
        let maxWidth = width - 16 // 减少内边距
        let titleHeight = user.nickname.height(withConstrainedWidth: maxWidth, font: .systemFont(ofSize: 14, weight: .medium))
        let signatureHeight = user.signature.height(withConstrainedWidth: maxWidth, font: .systemFont(ofSize: 12), numberOfLines: 2)
        
        // 总高度（减少间距）
        let totalHeight = imageHeight + titleHeight + signatureHeight + 12 // 减少总间距
        return CGSize(width: width, height: totalHeight)
    }
}

// MARK: - String Extension
private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont, numberOfLines: Int = 1) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let height = ceil(boundingBox.height)
        return numberOfLines > 0 ? min(height, font.lineHeight * CGFloat(numberOfLines)) : height
    }
}

// MARK: - UICollectionViewDataSource
extension HorizontalCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalAIUserCell", for: indexPath) as? HorizontalAIUserCell else {
            return UICollectionViewCell()
        }
        
        let user = users[indexPath.item]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HorizontalCategoryCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        delegate?.horizontalCategoryCell(self, didSelectUser: user)
    }
} 


class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        attributes?.forEach { attr in
            if attr.representedElementKind == nil { // not a supplementary view
                let finalAttribute = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: attr.indexPath)
                
                attr.frame.origin.y = finalAttribute?.frame.maxY ?? 0
            }
        }
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }
        
        let sectionInset = self.sectionInset.top
        let yOffset = sectionInset
        
        attributes.frame.origin.y = yOffset
        
        return attributes
    }
}
