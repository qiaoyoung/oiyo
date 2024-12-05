import UIKit
import SnapKit
import Moya

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.configure(with: message.lastMessage, isSender: message.isSender)
        return cell
    }
    
    
    private let ai: AIUserModel
    private var messages: [ChatItem] = [] // Store chat history
    private let provider = MoyaProvider<BigModelAPI>() // Create Moya Provider
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        return tv
    }()
    
    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false // Allow automatic height increase
        tv.delegate = self
        tv.returnKeyType = .send
        tv.layer.cornerRadius = 16
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        return tv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Type a message..."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(ColorManager.primary, for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        
        // Set border color based on gender
        view.layer.borderWidth = 2
        view.layer.borderColor = ai.gender == "male" ? UIColor.blue.cgColor : ColorManager.pink.cgColor
        
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.image = UIImage(named: ai.avatar)
        
        let nicknameLabel = UILabel()
        nicknameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nicknameLabel.textColor = ColorManager.textPrimary
        nicknameLabel.text = ai.nickname
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = ColorManager.textSecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = ai.desStr
        
        view.addSubview(avatarImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(descriptionLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            make.left.equalTo(nicknameLabel)
            make.right.equalToSuperview().offset(-12)
        }
        
        return view
    }()
    
    init(ai: AIUserModel) {
        self.ai = ai
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupNavigationBar()
        setupUI()
        loadMessages()
        scrollToLatestMessage()
    }
    
    private func setupNavigationBar() {
        // Set navigation bar opaque
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear // Remove bottom shadow
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
        
        title = "Chat with \(ai.nickname)"
    }
    
    private func setupUI() {
        title = "Chat with \(ai.nickname)"
        view.backgroundColor = .systemGroupedBackground
        
        // Create a container view to wrap infoCardView, adding some padding
        let headerContainerView = UIView()
        headerContainerView.backgroundColor = .clear
        
        // Add infoCardView to container view
        headerContainerView.addSubview(infoCardView)
        
        // Set fixed frame for container view
        let screenWidth = UIScreen.main.bounds.width
        headerContainerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 110) // Fixed height of 110
        
        // Set constraints for infoCardView
        infoCardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        // Set tableView's headerView
        tableView.tableHeaderView = headerContainerView
        
        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(messageTextView)
        inputContainerView.addSubview(placeholderLabel)
        inputContainerView.addSubview(sendButton)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainerView.snp.top)
        }
        
        inputContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.greaterThanOrEqualTo(60)
        }
        
        messageTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.height.lessThanOrEqualTo(100) // Maximum height limit
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.leading.equalTo(messageTextView).offset(12)
            make.top.equalTo(messageTextView).offset(12)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(messageTextView)
            make.width.equalTo(60)
            make.height.equalTo(36)
        }
    }
    
    private func loadMessages() {
        let key = "ChatHistory_\(ai.id)" // Use AI's ID as key
        if let data = UserDefaults.standard.data(forKey: key),
           let history = try? JSONDecoder().decode([ChatItem].self, from: data) {
            messages = history
        }
    }
    
    private func saveMessages() {
        let key = "ChatHistory_\(ai.id)" // Use AI's ID as key
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func scrollToLatestMessage() {
        guard !messages.isEmpty else { return }
        
        DispatchQueue.main.async {
            let lastIndex = self.messages.count - 1
            let indexPath = IndexPath(row: lastIndex, section: 0)
            
            // Ensure index is valid
            if lastIndex >= 0 && lastIndex < self.tableView.numberOfRows(inSection: 0) {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc private func handleSend() {
        guard let messageText = messageTextView.text, !messageText.isEmpty else { return }
        
        // Create new message item
        let newMessage = ChatItem(ai: ai, lastMessage: messageText, timestamp: Date(), isSender: true, isPinned: false)
        
        // Add message to chat history
        messages.append(newMessage)
        messageTextView.text = ""
        
        // Refresh table
        tableView.reloadData()
        
        // Scroll to latest message
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // Update title to "Typing..."
        self.title = "Typing..."
        
        // Send message to API
        let messageToSend: [[String: String]] = [["role": "user", "content": messageText]]
        
        provider.request(.chatCompletion(messages: messageToSend)) { result in
            // Update title to AI's name after request completes
            self.title = "Chat with \(self.ai.nickname)"
            
            switch result {
            case .success(let response):
                do {
                    // Parse successful response
                    let responseData = try JSONDecoder().decode(ChatResponse.self, from: response.data)
                    if let aiResponseMessage = responseData.choices.first?.message.content {
                        // Create AI's reply message item
                        let aiMessage = ChatItem(ai: self.ai, lastMessage: aiResponseMessage, timestamp: Date(), isSender: false, isPinned: false)
                        self.messages.append(aiMessage) // Add AI's reply to chat history
                        
                        // Refresh table
                        self.tableView.reloadData()
                        
                        // Scroll to latest message
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        
                        // Save chat history
                        self.saveMessages()
                        
                        // Send notification to update message list
                        NotificationCenter.default.post(name: .chatUpdated, object: nil)
                    }
                } catch {
                    print("Error decoding response: \(error)")
                }
            case .failure(let error):
                print("Error sending message: \(error)")
            }
        }
        
        // Save chat history and send notification
        saveMessages()
    }
}

// MARK: - ChatResponse 模型
struct ChatResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

// MARK: - UITextViewDelegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Update placeholder display state
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // Calculate new size
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        let height = min(estimatedSize.height, 100) // Limit maximum height
        
        // Update constraints
        messageTextView.snp.updateConstraints { make in
            make.height.lessThanOrEqualTo(height)
        }
        
        // Animate layout update
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Handle send button click
        if text == "\n" {
            handleSend()
            return false
        }
        
        // Limit input length
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
}