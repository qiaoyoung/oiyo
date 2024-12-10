import UIKit
import SnapKit

class AIDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let ai: AIUserModel
    private var isHeaderExpanded = false
    private var isFavorited: Bool = false {
        didSet {
            updateFavoriteButton()
        }
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerImageTapped))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var blurHeaderView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var startChatButton: GradientButton = {
        let button = GradientButton()
        button.setTitle("Start Chat", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(startChatTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    // Basic Information View
    private lazy var basicInfoView: AIBasicInfoView = {
        let view = AIBasicInfoView()
        return view
    }()
    
    // Feature Tags View
    private lazy var featuresView: AIFeaturesView = {
        let view = AIFeaturesView()
        return view
    }()
    
    // Sample Dialogs View
    private lazy var sampleDialogsView: AISampleDialogsView = {
        let view = AISampleDialogsView()
        return view
    }()
    
    // Statistics View
    private lazy var statsView: AIStatsView = {
        let view = AIStatsView()
        return view
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = ColorManager.primary
        return button
    }()
    
    // Add Description View
    private lazy var descriptionView: AIDescriptionView = {
        let view = AIDescriptionView()
        return view
    }()
    
    // MARK: - Initialization
    init(ai: AIUserModel) {
        self.ai = ai
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupUI()
        configureNavigationBar()
        configureData()
        loadFavoriteState()
        recordBrowsingHistory()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(headerImageView)
        scrollView.addSubview(blurHeaderView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(infoStackView)
        infoStackView.addArrangedSubview(descriptionView)
        infoStackView.addArrangedSubview(basicInfoView)
        infoStackView.addArrangedSubview(featuresView)
        infoStackView.addArrangedSubview(sampleDialogsView)
        infoStackView.addArrangedSubview(statsView)
        
        view.addSubview(startChatButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let headerHeight: CGFloat = UIScreen.main.bounds.width * 0.8
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(startChatButton.snp.top).offset(-20)
        }
        
        headerImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
            make.width.equalTo(scrollView.snp.width)
        }
        
        blurHeaderView.snp.makeConstraints { make in
            make.edges.equalTo(headerImageView)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(-20)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(scrollView)
            make.bottom.equalToSuperview()
        }
        
        infoStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16))
        }
        
        startChatButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(48)
        }
        
        infoStackView.spacing = 16
    }
    
    private func configureNavigationBar() {
        // 设置导航栏渐变效果
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // 收藏按钮
        let favoriteBarButton = UIBarButtonItem(customView: favoriteButton)
        navigationItem.rightBarButtonItem = favoriteBarButton
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func configureData() {
        headerImageView.image = UIImage(named: ai.avatar)
        
        // 配置描述信息
        descriptionView.configure(with: ai.desStr)
        
        // 配置基本信息
        basicInfoView.configure(with: ai)
        
        // 配置特性标签
        if !ai.features.isEmpty {
            featuresView.configure(with: ai.features)
            featuresView.isHidden = false
        } else {
            featuresView.isHidden = true
        }
        
        // 配置示例对话
        if !ai.sampleDialogs.isEmpty {
            sampleDialogsView.configure(with: ai.sampleDialogs)
            sampleDialogsView.isHidden = false
        } 
        
        // 配置统计信息
        statsView.configure(with: ai)
        
        // 设置底部按钮样式
        startChatButton.setGradientBackground()
    }
    
    private func loadFavoriteState() {
        // 从 UserDefaults 加载收藏状态
        let defaults = UserDefaults.standard
        let favoriteAIs = defaults.array(forKey: "FavoriteAIs") as? [String] ?? []
        isFavorited = favoriteAIs.contains(ai.id)
    }
    
    private func updateFavoriteButton() {
        favoriteButton.isSelected = isFavorited
        
        // 添加动画效果
        if isFavorited {
            UIView.animate(withDuration: 0.2, animations: {
                self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.favoriteButton.transform = .identity
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func headerImageTapped() {
        // 展示大图浏览器
        let imageViewer = AIImageViewerController(image: headerImageView.image)
        present(imageViewer, animated: true)
    }
    
    @objc private func startChatTapped() {
        let chatVC = ChatViewController(ai: ai)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func favoriteButtonTapped() {
        // 切换收藏状态
        isFavorited.toggle()
        
        // 保存到 UserDefaults
        let defaults = UserDefaults.standard
        var favoriteAIs = defaults.array(forKey: "FavoriteAIs") as? [String] ?? []
        
        if isFavorited {
            if !favoriteAIs.contains(ai.id) {
                favoriteAIs.append(ai.id)
            }
            // Show favorite success toast
            showFavoriteToast(message: "Added to Collection")
        } else {
            favoriteAIs.removeAll { $0 == ai.id }
            // Show unfavorite toast
            showFavoriteToast(message: "Removed from Collection")
        }
        
        defaults.set(favoriteAIs, forKey: "FavoriteAIs")
    }
    
    private func showFavoriteToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 15
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        view.addSubview(toastLabel)
        toastLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-40)
            make.height.equalTo(30)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIView.animate(withDuration: 0.3, animations: {
                    toastLabel.alpha = 0
                }) { _ in
                    toastLabel.removeFromSuperview()
                }
            }
        }
    }
    
    private func recordBrowsingHistory() {
        let historyItem = BrowsingHistoryItem(ai: ai, timestamp: Date())
        
        // 读取现有历史记录
        var historyItems: [BrowsingHistoryItem] = []
        if let data = UserDefaults.standard.data(forKey: "BrowsingHistory"),
           let history = try? JSONDecoder().decode([BrowsingHistoryItem].self, from: data) {
            historyItems = history
        }
        
        // 移除重复记录
        historyItems.removeAll { $0.ai.id == ai.id }
        
        // 加新记录
        historyItems.insert(historyItem, at: 0)
        
        // 限制历史记录数量
        if historyItems.count > 50 {
            historyItems = Array(historyItems.prefix(50))
        }
        
        // 保存历史记录
        if let data = try? JSONEncoder().encode(historyItems) {
            UserDefaults.standard.set(data, forKey: "BrowsingHistory")
        }
    }
}

// MARK: - UIScrollViewDelegate
extension AIDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // 处理头部图片视差效果
        if offsetY < 0 {
            headerImageView.transform = CGAffineTransform(translationX: 0, y: offsetY/2)
            blurHeaderView.alpha = 0
        } else {
            headerImageView.transform = .identity
            blurHeaderView.alpha = min(offsetY / 100, 0.6)
        }
    }
} 
