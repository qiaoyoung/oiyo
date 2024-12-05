import UIKit

class AnimatedTabBar: UITabBar {
    
    private var shapeLayer: CALayer?
    private var selectedItemIndex: Int = 0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 移除旧的形状层
        self.shapeLayer?.removeFromSuperlayer()
        
        // 创建新的形状层
        self.addShape()
    }
    
    private func addShape() {
        let shapeLayer = CALayer()
        shapeLayer.frame = bounds
        shapeLayer.backgroundColor = backgroundColor?.cgColor
        
        self.shapeLayer = shapeLayer
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 88 // 增加TabBar高度
        return sizeThatFits
    }
} 