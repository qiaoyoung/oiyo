import UIKit

class MoodCardView: UIView {
    
    private let mood: MoodPostModel
    private var isFlipped = false
    
    // 正面视图
    private let frontView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.secondary.withAlphaComponent(0.95)
        view.layer.cornerRadius = 15
        return view
    }()
    
    // 背面视图
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.primary.withAlphaComponent(0.95)
        view.layer.cornerRadius = 15
        view.isHidden = true
        return view
    }()
    
    // 正面内容
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = ColorManager.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // 背面内容
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    init(mood: MoodPostModel) {
        self.mood = mood
        super.init(frame: .zero)
        setupUI()
        configure(with: mood)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 添加阴影效果
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        
        // 添加子视图
        addSubview(frontView)
        addSubview(backView)
        
        frontView.addSubview(contentLabel)
        backView.addSubview(avatarImageView)
        backView.addSubview(nameLabel)
        
        // 设置约束
        frontView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func configure(with mood: MoodPostModel) {
        
        contentLabel.text = mood.content

        if mood.isMine {
            nameLabel.text = UserDataManager.shared.currentUser?.nickname
            // 设置头像
            if let avatarData = UserDataManager.shared.currentUser?.avatarData,
               let image = UIImage(data: avatarData) {
                avatarImageView.image = image
            } else {
                // 使用默认头像
                avatarImageView.image = UIImage(systemName: "person.circle.fill")
                avatarImageView.tintColor = ColorManager.primary
            }
        }else{
            nameLabel.text = mood.userName
            if let img = UIImage(named: mood.userAvatar) {
                avatarImageView.image = img
            }
        }
        
        // TODO: 设置头像
    }
    
    @objc private func handleTap() {
        flipCard()
    }
    
    private func flipCard() {
        let fromView = isFlipped ? backView : frontView
        let toView = isFlipped ? frontView : backView
        
        UIView.transition(from: fromView,
                         to: toView,
                         duration: 0.6,
                         options: [.transitionFlipFromRight, .showHideTransitionViews]) { [weak self] _ in
            self?.isFlipped.toggle()
        }
    }
    
    // 添加浮动动画
    func addFloatingAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.duration = Double.random(in: 2.0...3.0)
        animation.fromValue = -3
        animation.toValue = 3
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(animation, forKey: "floating")
    }
    
    // 添加呼吸动画
    func addBreathingAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = Double.random(in: 1.5...2.5)
        animation.fromValue = 0.95
        animation.toValue = 1.05
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(animation, forKey: "breathing")
    }
} 
