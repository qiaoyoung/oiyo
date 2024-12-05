import UIKit

class AnimatedTabBarItem: UITabBarItem {
    
    private var didSetup = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupObserver()
    }
    
    func setupObserver() {
        if !didSetup {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(itemSelected),
                name: NSNotification.Name("TabBarItemSelected"),
                object: nil
            )
            didSetup = true
        }
    }
    
    @objc private func itemSelected(_ notification: Notification) {
        guard let selectedItem = notification.object as? UITabBarItem,
              selectedItem == self else {
            return
        }
        animate()
    }
    
    private func animate() {
        guard let tabBar = self.value(forKey: "_tabBar") as? UITabBar,
              let index = tabBar.items?.firstIndex(of: self),
              let tabBarButton = tabBar.subviews[safe: index + 1],
              let imageView = tabBarButton.subviews.first else {
            return
        }
        
        // 弹跳动画
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = 0.6
        bounceAnimation.calculationMode = .cubic
        
        // 旋转动画
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = -0.1
        rotateAnimation.toValue = 0.1
        rotateAnimation.duration = 0.3
        rotateAnimation.autoreverses = true
        
        // 组合动画
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [bounceAnimation, rotateAnimation]
        animationGroup.duration = 0.6
        
        imageView.layer.add(animationGroup, forKey: "tabItemAnimation")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
