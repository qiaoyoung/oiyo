import UIKit
import SnapKit

class AISampleDialogsView: UIView {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Dialogs"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let dialogStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(titleLabel)
        addSubview(dialogStackView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        dialogStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configuration
    func configure(with dialogs: [AIUserModel.SampleDialog]) {
        dialogStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        dialogs.forEach { dialog in
            let questionBubble = createMessageBubble(text: dialog.question, isUser: true)
            let answerBubble = createMessageBubble(text: dialog.answer, isUser: false)
            
            dialogStackView.addArrangedSubview(questionBubble)
            dialogStackView.addArrangedSubview(answerBubble)
        }
    }
    
    private func createMessageBubble(text: String, isUser: Bool) -> UIView {
        let container = UIView()
        
        let bubble = UIView()
        bubble.backgroundColor = isUser ? .appPrimary.withAlphaComponent(0.1) : .systemGray6
        bubble.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = isUser ? .appPrimary : .black
        label.numberOfLines = 0
        
        container.addSubview(bubble)
        bubble.addSubview(label)
        
        bubble.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(280)
            make.leading.equalToSuperview().offset(isUser ? 60 : 0)
            make.trailing.equalToSuperview().offset(isUser ? 0 : -60)
        }
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        return container
    }
} 