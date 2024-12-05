import UIKit
import SnapKit

class SettingsViewController: UIViewController {
    
    private enum Section: Int, CaseIterable {
        case settings
        
        var title: String {
            switch self {
            case .settings: return "设置"
            }
        }
    }
    
    private var settings: [Section: [SettingItem]] = [:]
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .systemGroupedBackground
        tv.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupUI()
        setupSettings()
    }
    
    private func setupUI() {
        title = "设置"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupSettings() {
        // 所有设置项
        settings[.settings] = [
            SettingItem(
                icon: "person.circle.fill",
                title: "个人资料",
                detail: nil,
                type: .arrow
            ) { [weak self] in
                self?.handleProfile()
            }
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    private func handleProfile() {
        // TODO: 跳转到个人资料页面
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section),
              let items = settings[section] else { return 0 }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        
        if let section = Section(rawValue: indexPath.section),
           let items = settings[section] {
            cell.configure(with: items[indexPath.row])
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let section = Section(rawValue: indexPath.section),
           let items = settings[section] {
            items[indexPath.row].action()
        }
    }
} 
