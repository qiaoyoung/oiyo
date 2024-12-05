import UIKit
import SnapKit

class ChatMessageCell: UITableViewCell {
    
    private let messageBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private var isSender: Bool = false // 用于区分发送方和接收方
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(messageBubbleView)
        messageBubbleView.addSubview(messageLabel)
        
        messageBubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.7) // 限制气泡宽度
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    func configure(with message: String, isSender: Bool) {
        messageLabel.text = message
        self.isSender = isSender
        
        // 设置气泡颜色和布局
        if isSender {
            messageBubbleView.backgroundColor = ColorManager.primary.withAlphaComponent(0.1)
            messageBubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.7) // 限制气泡宽度
                make.right.equalToSuperview().offset(-12)
            }
        } else {
            messageBubbleView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            messageBubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.7) // 限制气泡宽度
                make.left.equalToSuperview().offset(12)
            }
        }
    }
} 
