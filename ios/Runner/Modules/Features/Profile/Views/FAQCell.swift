import UIKit
import SnapKit

class FAQCell: UITableViewCell {
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorManager.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorManager.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerLabel)
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(questionLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(question: String, answer: String) {
        questionLabel.text = question
        answerLabel.text = answer
    }
} 