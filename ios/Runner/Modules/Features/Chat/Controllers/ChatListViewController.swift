import UIKit
import SnapKit

class ChatListViewController: UIViewController {
    
    private var chatItems: [ChatItem] = [] // Store all chat records
    private var filteredChatItems: [ChatItem] = [] // Store filtered chat records
    private var isSearching: Bool = false // Flag for search state
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search chat history"
        return sc
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var guideLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.textSecondary
        label.numberOfLines = 0
        label.text = "Here, you can engage in conversations with AI assistants, spark creative inspiration, and explore endless possibilities"
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tv.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        return tv
    }()
    
    private lazy var emptyView: EmptyStateView = {
        let view = EmptyStateView(title: "Inspiration Chat Empty")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        
        // Register long press gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleChatUpdate), name: .chatUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        navigationController?.title = "Inspiration"
        view.backgroundColor = .systemGroupedBackground
        
        // Set search controller
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Set header view
        setupHeaderView()
        
        view.addSubview(tableView)
        view.addSubview(emptyView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupHeaderView() {
        headerView.addSubview(guideLabel)
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 60)
        
        guideLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
        
        tableView.tableHeaderView = headerView
    }
    
    private func loadData() {
        chatItems.removeAll() // Clear existing data
        
        // Get all AI users
        let aiUsers = AIUserDataManager.shared.aiUsers
        
        // Iterate through all AI users, check if there's chat history
        for ai in aiUsers {
            let key = "ChatHistory_\(ai.id)" // Use AI's ID as key
            if let data = UserDefaults.standard.data(forKey: key),
               let history = try? JSONDecoder().decode([ChatItem].self, from: data),
               let lastMessage = history.last { // Get the last message
                // Check if the same AI assistant already exists
                if !chatItems.contains(where: { $0.ai.id == lastMessage.ai.id }) {
                    chatItems.append(lastMessage) // Only keep the last message
                }
            }
        }
        
        // Sort by timestamp in descending order
        chatItems.sort { $0.timestamp > $1.timestamp }
        
        // Update UI
        updateUI()
    }
    
    private func updateUI() {
        let items = isSearching ? filteredChatItems : chatItems
        emptyView.isHidden = !items.isEmpty
        tableView.reloadData()
    }
    
    @objc private func handleChatUpdate() {
        loadData()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                showActionSheet(for: indexPath)
            }
        }
    }
    
    private func showActionSheet(for indexPath: IndexPath) {
        let chatItem = isSearching ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Pin/Unpin
        let pinTitle = chatItem.isPinned ? "Unpin" : "Pin"
        let pinAction = UIAlertAction(title: pinTitle, style: .default) { [weak self] _ in
            self?.togglePin(at: indexPath)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteChat(at: indexPath)
        }
        // Delete
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(pinAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func togglePin(at indexPath: IndexPath) {
        var chatItem = isSearching ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        chatItem.isPinned.toggle()
        
        // Update data source
        if isSearching {
            filteredChatItems[indexPath.row] = chatItem
            if let originalIndex = chatItems.firstIndex(where: { $0.ai.id == chatItem.ai.id }) {
                chatItems[originalIndex] = chatItem
            }
        } else {
            chatItems[indexPath.row] = chatItem
        }
        
        // Re-sort: pinned items come first
        sortChatItems()
        
        // Save update
        saveChatItems()
        
        // Refresh UI
        tableView.reloadData()
    }
    
    private func deleteChat(at indexPath: IndexPath) {
        let chatItem = isSearching ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        
        // Remove from data source
        if isSearching {
            filteredChatItems.remove(at: indexPath.row)
            if let originalIndex = chatItems.firstIndex(where: { $0.ai.id == chatItem.ai.id }) {
                chatItems.remove(at: originalIndex)
            }
        } else {
            chatItems.remove(at: indexPath.row)
        }
        
        // Delete chat history from local storage
        let key = "ChatHistory_\(chatItem.ai.id)"
        UserDefaults.standard.removeObject(forKey: key)
        
        // Save update
        saveChatItems()
        
        // Refresh UI
        tableView.deleteRows(at: [indexPath], with: .automatic)
        updateUI()
    }
    
    private func sortChatItems() {
        // First sort by pinned state, then by timestamp
        chatItems.sort { (item1, item2) -> Bool in
            if item1.isPinned != item2.isPinned {
                return item1.isPinned
            }
            return item1.timestamp > item2.timestamp
        }
    }
    
    private func saveChatItems() {
        // Save chat list state (including pinned state)
        if let data = try? JSONEncoder().encode(chatItems) {
            UserDefaults.standard.set(data, forKey: "ChatList")
        }
    }
}

// MARK: - UITableViewDataSource
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredChatItems.count : chatItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        let chatItem = isSearching ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        cell.configure(with: chatItem)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatItem = isSearching ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        let chatVC = ChatViewController(ai: chatItem.ai)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ChatListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            isSearching = false
            updateUI()
            return
        }
        
        isSearching = true
        
        // Search based on AI name and last message content
        filteredChatItems = chatItems.filter { item in
            return item.ai.nickname.lowercased().contains(searchText) ||
                   item.lastMessage.lowercased().contains(searchText)
        }
        
        updateUI()
    }
}
