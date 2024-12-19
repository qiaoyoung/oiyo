import Flutter
import UIKit
import IQKeyboardManagerSwift
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
          if #available(iOS 14, *) {
              ATTrackingManager.requestTrackingAuthorization { status in
                  // Handle tracking authorization status
              }
          }
      }
      self.window = UIWindow.init(frame: UIScreen.main.bounds)
      self.window?.backgroundColor = .white
      self.window?.makeKeyAndVisible()
      // 检查是否已登录
      if UserDataManager.shared.isUserLoggedIn {
          let mainTabBarController = MainTabBarController()
          self.window?.rootViewController = mainTabBarController
      } else {
          let pViewController = PortalViewController()
          self.window?.rootViewController = pViewController
      }
      // 配置 IQKeyboardManager
      IQKeyboardManager.shared.enable = true
      IQKeyboardManager.shared.shouldResignOnTouchOutside = true // 点击空白处收起键盘
      IQKeyboardManager.shared.enableAutoToolbar = false // 如果不需要自动工具条可以设置为 false
      
      return true
  }
}
