import UIKit
import SnapKit

class HistoryViewController: UIViewController {
    
    private var historyItems: [BrowsingHistoryItem] = []
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .systemBackground
        tv.separatorStyle = .none
        tv.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        title = "Browse History"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Add clear button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(handleClear)
        )
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "BrowsingHistory"),
           let history = try? JSONDecoder().decode([BrowsingHistoryItem].self, from: data) {
            // Sort by timestamp in descending order
            historyItems = history.sorted { $0.timestamp > $1.timestamp }
            updateUI()
        } else {
            historyItems = []
            updateUI()
        }
    }
    
    private func updateUI() {
        tableView.updateEmptyState(
            isEmpty: historyItems.isEmpty,
            message: "No browsing history"
        )
        tableView.reloadData()
    }
    
    @objc private func handleClear() {
        guard !historyItems.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Clear History",
            message: "Are you sure you want to clear all browsing history?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            self?.clearHistory()
        })
        
        present(alert, animated: true)
    }
    
    private func clearHistory() {
        historyItems.removeAll()
        UserDefaults.standard.removeObject(forKey: "BrowsingHistory")
        updateUI()
        
        // Show success message
        let message = "History cleared"
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        
        // Delay removal of the message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.3) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let item = historyItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = historyItems[indexPath.row]
        let detailVC = AIDetailViewController(ai: item.ai)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
} 
