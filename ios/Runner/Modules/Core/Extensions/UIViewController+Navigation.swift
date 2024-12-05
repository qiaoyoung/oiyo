import UIKit

extension UIViewController {
    func setupCustomBackButton() {
        // 自定义返回按钮
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackButtonTapped)
        )
        backButton.tintColor = ColorManager.primary
        navigationItem.leftBarButtonItem = backButton
        
        // 隐藏默认的返回按钮文字
        navigationItem.backButtonTitle = ""
    }
    
    @objc private func handleBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
} 