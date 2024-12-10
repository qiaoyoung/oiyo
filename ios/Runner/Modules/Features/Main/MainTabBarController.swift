import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // 使用自定义TabBar
        let customTabBar = AnimatedTabBar()
        self.setValue(customTabBar, forKey: "tabBar")
        
        setupAppearance()
        setupViewControllers()
    }
    
    private func setupAppearance() {
        // 设置TabBar外观
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 移除模糊效果，使用纯色背景
        appearance.backgroundEffect = nil
        
        // 设置选中和未选中的颜色
        appearance.stackedLayoutAppearance.selected.iconColor = .appPrimary
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.appPrimary,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
        let viewControllers: [(UIViewController, String, String, String)] = [
            (PlazaViewController(), "Knowledge", "square.grid.2x2", "square.grid.2x2.fill"),
            (ChatListViewController(), "Inspiration", "message", "message.fill"),
            (DiscoveryViewController(), "Mood Square", "heart.square", "heart.square.fill"),
            (ProfileViewController(), "Planet Station", "person.circle", "person.circle.fill")
        ]
        
        self.viewControllers = viewControllers.map { viewController, title, image, selectedImage in
            let navController = createNavController(
                for: viewController,
                title: title,
                image: image,
                selectedImage: selectedImage
            )
            // 使用自定义的TabBarItem
            let tabBarItem = AnimatedTabBarItem(
                title: title,
                image: UIImage(systemName: image),
                selectedImage: UIImage(systemName: selectedImage)
            )
            navController.tabBarItem = tabBarItem
            return navController
        }
    }
    
    private func createNavController(for rootViewController: UIViewController,
                                   title: String,
                                   image: String,
                                   selectedImage: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.title = title
        
        // 设置导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        
        return navController
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let item = viewController.tabBarItem {
            NotificationCenter.default.post(
                name: NSNotification.Name("TabBarItemSelected"),
                object: item
            )
        }
    }
} 
