import UIKit
import SnapKit

class MyMoodsViewController: UIViewController {
    
    private lazy var emptyView: EmptyStateView = {
        let view = EmptyStateView(title: "No Moods Yet")
        view.isHidden = true
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.register(MyMoodCell.self, forCellReuseIdentifier: "MyMoodCell")
        return tv
    }()
    
   
    
    private var moods: [MoodPostModel] = [] {
        didSet {
            tableView.reloadData()
            updateEmptyState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMoods()
    }
    
    private func setupUI() {
        title = "My Moods"
        view.backgroundColor = .systemGroupedBackground
        setupCustomBackButton()
        
        view.addSubview(tableView)
        view.addSubview(emptyView)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
   
    private func loadMoods() {
        
        moods = UserDataManager.shared.getUserMoods()
    }
    
    private func updateEmptyState() {
        emptyView.isHidden = !moods.isEmpty
    }
}

// MARK: - UITableViewDataSource
extension MyMoodsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMoodCell", for: indexPath) as! MyMoodCell
        let mood = moods[indexPath.row]
        cell.configure(with: mood)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyMoodsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            let mood = self?.moods[indexPath.row]
            if let mood = mood {
                UserDataManager.shared.deleteMood(withId: mood.id)
                self?.loadMoods()
            }
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
} 
