import UIKit
import SnapKit

class DiscoveryViewController: UIViewController, UISearchBarDelegate {
    
    private var moodItems: [MoodPostModel] = []
    private var aiUsers: [AIUserModel] = []
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.alwaysBounceVertical = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorManager.primary
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ColorManager.primary.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(handlePostMood), for: .touchUpInside)
        return button
    }()
    
    private lazy var musicButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "music.note"), for: .normal)
        button.tintColor = ColorManager.primary
        button.addTarget(self, action: #selector(handleMusicToggle), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Planet Station"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover More AI Assistants"
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search AI assistants..."
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var emptyView: EmptyStateView = {
        let view = EmptyStateView(title: "No Results Found")
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadAIUsers()
        startBackgroundMusic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 检查音乐播放状态并更新旋转动画
        if MusicPlayerManager.shared.playing {
            addRotationEffect()
        } else {
            removeRotationEffect()
        }
        
        // 重新为所有卡片添加动画
        contentView.subviews.forEach { view in
            if let cardView = view as? MoodCardView {
                cardView.addFloatingAnimation()
                cardView.addBreathingAnimation()
                
                // 添加随机旋转
                let rotation = CGFloat.random(in: -0.05...0.05)
                cardView.transform = CGAffineTransform(rotationAngle: rotation)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 移除所有卡片的动画
        contentView.subviews.forEach { view in
            if let cardView = view as? MoodCardView {
                cardView.layer.removeAllAnimations()
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.background
        title = "Mood Square"
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(postButton)
        view.addSubview(musicButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
            make.width.equalTo(0)
        }
        
        postButton.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        musicButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.trailing.equalTo(postButton)
            make.bottom.equalTo(postButton.snp.top).offset(-16)
        }
        
        updateMusicButtonState()
    }
    
    private func setupNavigationBar() {
        // 设置导航栏的背景色
        navigationController?.navigationBar.barTintColor = .white
        
        // 添加音乐按钮到导航栏
        let musicBarButton = UIBarButtonItem(customView: musicButton)
        navigationItem.rightBarButtonItem = musicBarButton
        
        // 更新音乐按钮状态
        updateMusicButtonState()
    }
    
    private func loadData() {
        loadAIUsers()
        loadUserMoods()
    }
    
    private func refreshDisplay() {
        // 重新打乱AI用户数据
        aiUsers.shuffle()
        // 重新显示所数据
        displayMoods()
        // 滚动到开头
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    private func loadAIUsers() {
        aiUsers = AIUserDataManager.shared.aiUsers
        displayMoods()
    }
    
    private func loadUserMoods() {
        moodItems = UserDataManager.shared.getUserMoods()
        displayMoods()
    }
    
    private func saveUserMoods() {
        UserDataManager.shared.saveUserMoods(moodItems: moodItems)
    }
    
    private func displayMoods() {
        // 清除现有视图
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 合并AI心情和用户心情
        var allMoods = aiUsers.map { aiUser in
            return MoodPostModel(id: aiUser.id,
                                 userId: aiUser.id,
                                 userAvatar: aiUser.avatar,
                                 userName: aiUser.nickname,
                                 content: aiUser.moodPhrase,
                                 mood: .happy,
                                 timestamp: Date(),
                                 isMine: false)
        }
        
        // 添加用户发布的心情
        allMoods.append(contentsOf: moodItems)
        
        // 随机打乱顺序
        allMoods.shuffle()
        
        // 布局参数
        let cardWidth: CGFloat = 160
        let cardHeight: CGFloat = 200
        let horizontalSpacing: CGFloat = 20
        let verticalSpacing: CGFloat = 20
        let rows = 3
        
        var currentX: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        // 创建并布局卡片
        for (index, mood) in allMoods.enumerated() {
            let row = index % rows
            let column = index / rows
            
            let cardView = MoodCardView(mood: mood)
            contentView.addSubview(cardView)
            
            let x = CGFloat(column) * (cardWidth + horizontalSpacing)
            let y = CGFloat(row) * (cardHeight + verticalSpacing) + verticalSpacing
            
            cardView.snp.makeConstraints { make in
                make.left.equalTo(x)
                make.top.equalTo(y)
                make.width.equalTo(cardWidth)
                make.height.equalTo(cardHeight)
            }
            
            // 添加入场动画
            cardView.alpha = 0
            cardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.6, delay: Double(index) * 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                cardView.alpha = 1
                cardView.transform = .identity
            }
            
            // 添加动画
            cardView.addFloatingAnimation()
            cardView.addBreathingAnimation()
            
            // 添加随机旋转
            let rotation = CGFloat.random(in: -0.05...0.05)
            cardView.transform = CGAffineTransform(rotationAngle: rotation)
            
            maxWidth = max(maxWidth, x + cardWidth)
        }
        
        // 设置contentView的宽度
        contentView.snp.updateConstraints { make in
            make.width.equalTo(maxWidth + horizontalSpacing * 2)
        }
        
        // 强制布局更新
        view.layoutIfNeeded()
    }
    
    @objc private func handlePostMood() {
        let postVC = PostMoodViewController { [weak self] newMood in
            self?.handleNewMood(newMood)
        }
        let nav = UINavigationController(rootViewController: postVC)
        present(nav, animated: true)
    }
    
    private func handleNewMood(_ mood: MoodPostModel) {
        // 添加到心情列表
        moodItems.insert(mood, at: 0)
        
        // 保存到本地
        saveUserMoods()
        
        // 刷新显示
        displayMoods()
        
        // 滚动到开头
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    private func startBackgroundMusic() {
        MusicPlayerManager.shared.play()
        updateMusicButtonState()
    }
    
    private func updateMusicButtonState() {
        let imageName = MusicPlayerManager.shared.playing ? "music.note" : "pause"
        musicButton.setImage(UIImage(systemName: imageName), for: .normal)
        // 添加旋转效果
        if MusicPlayerManager.shared.playing {
            addRotationEffect()
        } else {
            removeRotationEffect()
        }
    }
    
    @objc private func handleMusicToggle() {
        MusicPlayerManager.shared.togglePlayPause()
        
        // 添加按钮动画
        UIView.animate(withDuration: 0.2, animations: {
            self.musicButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.musicButton.transform = .identity
            }
        }
        
        // 根据播放状态更新旋转动画
        if MusicPlayerManager.shared.playing {
            addRotationEffect()
        } else {
            removeRotationEffect()
        }
        
        // 更新按钮状态
        updateMusicButtonState()
        
        // 添加触感反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func addRotationEffect() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 2
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = .infinity
        musicButton.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func removeRotationEffect() {
        musicButton.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
}
