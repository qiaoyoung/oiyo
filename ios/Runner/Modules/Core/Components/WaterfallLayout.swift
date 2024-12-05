import UIKit

protocol WaterfallLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, heightForHeaderIn section: Int) -> CGFloat
}

class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: WaterfallLayoutDelegate?
    
    private var columnCount: Int = 2
    private var spacing: CGFloat = 10
    private var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var headerAttributes: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width - contentInsets.left - contentInsets.right
    }
    
    private var columnWidths: [CGFloat] = []
    private var columnHeights: [CGFloat] = []
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        layoutAttributes.removeAll()
        headerAttributes.removeAll()
        contentHeight = 0
        
        let numberOfSections = collectionView.numberOfSections
        
        for section in 0..<numberOfSections {
            let headerHeight = delegate?.collectionView(collectionView, heightForHeaderIn: section) ?? 0
            
            // 添加header属性
            if headerHeight > 0 {
                let headerIndexPath = IndexPath(item: 0, section: section)
                let headerAttributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: headerIndexPath
                )
                headerAttributes.frame = CGRect(
                    x: contentInsets.left,
                    y: contentHeight,
                    width: contentWidth,
                    height: headerHeight
                )
                self.headerAttributes.append(headerAttributes)
                contentHeight += headerHeight + spacing
            }
            
            // 重置列高度
            columnHeights = Array(repeating: contentHeight, count: columnCount)
            
            let itemCount = collectionView.numberOfItems(inSection: section)
            let columnWidth = (contentWidth - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)
            columnWidths = Array(repeating: columnWidth, count: columnCount)
            
            // 计算每个item的布局
            for item in 0..<itemCount {
                let indexPath = IndexPath(item: item, section: section)
                let height = delegate?.collectionView(collectionView, heightForItemAt: indexPath) ?? 100
                
                let minColumnIndex = columnHeights.firstIndex(of: columnHeights.min() ?? 0) ?? 0
                let xOffset = contentInsets.left + (columnWidth + spacing) * CGFloat(minColumnIndex)
                let yOffset = columnHeights[minColumnIndex]
                
                let frame = CGRect(x: xOffset, y: yOffset, width: columnWidth, height: height)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                layoutAttributes.append(attributes)
                
                columnHeights[minColumnIndex] = yOffset + height + spacing
                contentHeight = max(contentHeight, columnHeights[minColumnIndex])
            }
            
            // 添加section间距
            if section < numberOfSections - 1 {
                contentHeight += spacing
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleAttributes = layoutAttributes.filter { rect.intersects($0.frame) }
        let visibleHeaders = headerAttributes.filter { rect.intersects($0.frame) }
        return visibleAttributes + visibleHeaders
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes.first { $0.indexPath == indexPath }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return headerAttributes.first { $0.indexPath.section == indexPath.section }
        }
        return nil
    }
} 