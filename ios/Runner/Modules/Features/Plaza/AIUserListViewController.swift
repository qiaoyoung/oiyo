import UIKit

class AIUserListViewController: UIViewController {
    
    // MARK: - Properties
    private let category: AIUserCategory
    private var users: [AIUserModel]
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AIUserCell.self, forCellWithReuseIdentifier: "AIUserCell")
        return collectionView
    }()
    
    // MARK: - Initialization
    init(category: AIUserCategory) {
        self.category = category
        self.users = category.users
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = category.title
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AIUserListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AIUserCell", for: indexPath) as? AIUserCell else {
            return UICollectionViewCell()
        }
        
        let user = users[indexPath.item]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AIUserListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        let detailVC = AIDetailViewController(ai: user)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - WaterfallLayoutDelegate
extension AIUserListViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForHeaderIn section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let width = (collectionView.bounds.width - 30) / 2 // 考虑间距
        let user = users[indexPath.item]
        
        // 获取图片实际尺寸
        let imageHeight: CGFloat
        if let image = UIImage(named: user.avatar) {
            let ratio = image.size.height / image.size.width
            imageHeight = width * ratio
        } else {
            imageHeight = width // 如果无法获取图片，使用默认的1:1比例
        }
        
        let titleHeight: CGFloat = 20
        let descriptionHeight: CGFloat = 40
        let padding: CGFloat = 20
        
        return imageHeight + titleHeight + descriptionHeight + padding
    }
} 
