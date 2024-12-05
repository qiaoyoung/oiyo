import UIKit
import SnapKit

class AIStatsView: UIView {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Statistics"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    
    private let ratingView = StatItemView(title: "Rating")
    private let chatsView = StatItemView(title: "Total Chats")
    private let daysView = StatItemView(title: "Active Days")
    
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
        addSubview(statsStackView)
        
        statsStackView.addArrangedSubview(ratingView)
        statsStackView.addArrangedSubview(chatsView)
        statsStackView.addArrangedSubview(daysView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configuration
    func configure(with ai: AIUserModel) {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: 0), to: Date()).day ?? 0
        
        ratingView.configure(value: String(format: "%.1f", ai.rating))
        chatsView.configure(value: "\(ai.totalChats)")
        daysView.configure(value: "\(daysSinceCreation)")
    }
}

// MARK: - StatItemView
private class StatItemView: UIView {
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .appPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(valueLabel)
        addSubview(titleLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(value: String) {
        valueLabel.text = value
    }
} 