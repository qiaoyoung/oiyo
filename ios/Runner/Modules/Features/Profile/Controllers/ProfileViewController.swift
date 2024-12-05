import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    private enum Section: Int, CaseIterable {
        case header         // User info header
        case features      // Features
        case about         // About
        
        var title: String {
            switch self {
            case .header: return ""
            case .features: return "Features"
            case .about: return "Other"
            }
        }
    }
    
    private var menuData: [Section: [MenuItem]] = [:]
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.register(ProfileHeaderCell.self, forCellReuseIdentifier: "ProfileHeaderCell")
        tv.register(ProfileMenuCell.self, forCellReuseIdentifier: "ProfileMenuCell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenuData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Planet Station"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupMenuData() {
        // User info header
        menuData[.header] = []
        
        // Features
        menuData[.features] = [
            MenuItem(
                icon: "heart.fill",
                title: "My Collection",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleCollection()
            },
            MenuItem(
                icon: "clock.fill",
                title: "Browse History",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleHistory()
            },
            MenuItem(
                icon: "square.and.pencil",
                title: "My Moods",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleMyMoods()
            }
        ]
        
        // About
        menuData[.about] = [
            MenuItem(
                icon: "info.circle.fill",
                title: "App Introduction",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleAppIntro()
            },
            MenuItem(
                icon: "questionmark.circle.fill",
                title: "AI Usage",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleAIUsage()
            },
            MenuItem(
                icon: "doc.fill",
                title: "Terms of Service",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleUserAgreement()
            },
            MenuItem(
                icon: "shield.fill",
                title: "Privacy Policy",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handlePrivacyPolicy()
            },
            MenuItem(
                icon: "trash.fill",
                title: "Clear Cache",
                subtitle: calculateCacheSize(),
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleClearCache()
            },
            MenuItem(
                icon: "exclamationmark.bubble.fill",
                title: "Feedback",
                subtitle: nil,
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleFeedback()
            },
            MenuItem(
                icon: "info.circle.fill",
                title: "About Us",
                subtitle: "Version 1.0.0",
                type: .arrow,
                showArrow: true
            ) { [weak self] in
                self?.handleAbout()
            },
        ]
        
        // Refresh UI
        tableView.reloadData()
    }
    
    // MARK: - Actions
   
    private func handleCollection() {
        let vc = CollectionViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleHistory() {
        let vc = HistoryViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleMyMoods() {
        let vc = MyMoodsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSettings() {
        let vc = SettingsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    private func updateUI() {
        // Refresh table data
        tableView.reloadData()
    }
    
    private func handleClearCache() {
        let alert = UIAlertController(
            title: "Clear Cache",
            message: "Are you sure you want to clear all cache?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // 执行清除缓存操作
            self.clearCache { success in
                DispatchQueue.main.async {
                    if success {
                        // 显示成功提示
                        let successAlert = UIAlertController(
                            title: "Success",
                            message: "Cache cleared successfully",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(successAlert, animated: true)
                        
                        // 更新菜单显示
                        self.setupMenuData()
                    } else {
                        // 显示错误提示
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "Failed to clear cache",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func clearCache(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let fileManager = FileManager.default
            guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
                completion(false)
                return
            }
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: cachePath)
                for file in files {
                    let path = (cachePath as NSString).appendingPathComponent(file)
                    try fileManager.removeItem(atPath: path)
                }
                completion(true)
            } catch {
                print("Clear cache error: \(error)")
                completion(false)
            }
        }
    }
    
    private func handleUserAgreement() {
        let webVC = WebViewController(url: "https://sites.google.com/view/oiyo2024/home", title: "Terms of Service")
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    private func handlePrivacyPolicy() {
        let webVC = WebViewController(url: "https://sites.google.com/view/oiyoprivacy/home", title: "Privacy Policy")
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    private func handleAppIntro() {
        let vc = AppIntroViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleAbout() {
        let aboutVC = AboutUsViewController()
        aboutVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    private func handleAIUsage() {
        let faqVC = FAQDetailViewController()
        faqVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(faqVC, animated: true)
    }
    
    private func handleFeedback() {
        let vc = FeedbackViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func calculateCacheSize() -> String {
        let fileManager = FileManager.default
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return "0MB"
        }
        
        guard let files = try? fileManager.contentsOfDirectory(atPath: cachePath) else {
            return "0MB"
        }
        
        var size: Int64 = 0
        for file in files {
            let path = (cachePath as NSString).appendingPathComponent(file)
            guard let attributes = try? fileManager.attributesOfItem(atPath: path) else { continue }
            size += attributes[.size] as? Int64 ?? 0
        }
        
        // Convert to appropriate unit
        if size < 1024 {
            return "\(size)B"
        } else if size < 1024 * 1024 {
            return String(format: "%.1fKB", Double(size) / 1024.0)
        } else if size < 1024 * 1024 * 1024 {
            return String(format: "%.1fMB", Double(size) / 1024.0 / 1024.0)
        } else {
            return String(format: "%.1fGB", Double(size) / 1024.0 / 1024.0 / 1024.0)
        }
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        if section == .header {
            return 1
        }
        return menuData[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        if section == .header {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as! ProfileHeaderCell
            cell.delegate = self
            if let currentUser = UserDataManager.shared.currentUser {
                cell.configure(with: currentUser)
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuCell", for: indexPath) as! ProfileMenuCell
        if let items = menuData[section] {
            cell.configure(with: items[indexPath.row])
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else { return 0 }
        if section == .header {
            return 120
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else { return 0 }
        return section == .header ? 0 : 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section),
              section != .header,
              let items = menuData[section] else { return }
        
        items[indexPath.row].action()
    }
}

extension ProfileViewController: ProfileHeaderCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func profileHeaderCellDidTapAvatar(_ cell: ProfileHeaderCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .camera)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Choose from Photo Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    func profileHeaderCellDidTapNickname(_ cell: ProfileHeaderCell) {
        let alert = UIAlertController(title: "Change Nickname", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter new nickname"
            textField.text = UserDataManager.shared.currentUser?.nickname
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let nickname = alert.textFields?.first?.text, !nickname.isEmpty {
                // Update user nickname
                UserDataManager.shared.updateUserNickname(nickname)
                // Refresh UI
                self?.tableView.reloadData()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.jpegData(compressionQuality: 0.5) {
            // Update user avatar
            UserDataManager.shared.updateUserAvatar(imageData)
            // Refresh UI
            tableView.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
} 
