import UIKit

class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func setGradientBackground() {
        // 使用主题色创建渐变
        let startColor = UIColor.appPrimary
        let endColor = UIColor.appSecondary
        
        gradientLayer.colors = [
            startColor.cgColor,
            endColor.cgColor
        ]
        
        // 添加动画效果
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = [
            endColor.cgColor,
            startColor.cgColor
        ]
        animation.duration = 3.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
    
    func removeGradientBackground() {
        gradientLayer.removeAllAnimations()
        gradientLayer.colors = nil
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.6
        }
    }
} 