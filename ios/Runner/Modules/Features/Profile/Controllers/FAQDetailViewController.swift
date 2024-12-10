import UIKit
import SnapKit

class FAQDetailViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .systemGroupedBackground
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tv
    }()
    
    private var items: [(title: String, content: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupItems()
    }
    
    private func setupUI() {
        title = "AI Usage Guide"
        view.backgroundColor = .systemGroupedBackground
        setupCustomBackButton()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupItems() {
        items = [
            (
                title: "What is Planet Station?",
                content: "Planet Station is an AI assistant platform that provides intelligent dialogue services. Here, you can chat with different AI assistants to get inspiration and help."
            ),
            (
                title: "How to start a conversation?",
                content: "Simply select an AI assistant you're interested in, then click to enter the chat interface. You can start typing your message and send it to begin the conversation."
            ),
            (
                title: "What can AI assistants help with?",
                content: "Our AI assistants can help with creative writing, technical consulting, life planning, and more. Each assistant has their own expertise to provide professional advice in different areas."
            ),
            (
                title: "How to get better responses?",
                content: "To get better responses, try to: 1. Ask clear and specific questions 2. Provide necessary context 3. Break down complex questions into smaller parts 4. Use follow-up questions for clarification"
            ),
            (
                title: "Is my chat history saved?",
                content: "Yes, your chat history is saved locally on your device. You can view past conversations in the chat history section. You can also clear the chat history in settings if needed."
            )
        ]
    }
}

// MARK: - UITableViewDataSource
extension FAQDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.section]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.content
        content.textProperties.numberOfLines = 0
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].title
    }
}

// MARK: - UITableViewDelegate
extension FAQDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
} 
