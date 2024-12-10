import UIKit
import SnapKit

class CollectionViewController: UIViewController {
    
    private var collectedAIs: [AIUserModel] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(CollectionAICell.self, forCellWithReuseIdentifier: "CollectionAICell")
        cv.contentInsetAdjustmentBehavior = .always
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        title = "My Collection"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadData() {
        // 从本地加载收藏的AI
        if let favoriteAIIds = UserDefaults.standard.array(forKey: "FavoriteAIs") as? [String]{
            collectedAIs = AIUserDataManager.shared.aiUsers.filter { favoriteAIIds.contains($0.id) }
            updateUI()
        }else {
            collectedAIs = []
            updateUI()
        }
    }
    
    private func updateUI() {
        collectionView.updateEmptyState(
            isEmpty: collectedAIs.isEmpty,
            message: "No AI assistants collected yet"
        )
        collectionView.reloadData()
    }
    
    private func unfavoriteAI(at index: Int) {
        let ai = collectedAIs[index]
        
        // 更新本地存储
        if var favoriteAIIds = UserDefaults.standard.array(forKey: "FavoriteAIs") as? [String] {
            favoriteAIIds.removeAll { $0 == ai.id }
            UserDefaults.standard.set(favoriteAIIds, forKey: "FavoriteAIs")
        }
        
        // 更新数据源
        collectedAIs.remove(at: index)
        
        // 更新UI
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
        
        // 显示提示
        let message = "Removed from collection"
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        
        // 延迟移除提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.3) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }
    
    private func showUnfavoriteAlert(for index: Int) {
        let alert = UIAlertController(
            title: "Remove from Collection",
            message: "Are you sure you want to remove this AI assistant from your collection?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            self?.unfavoriteAI(at: index)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectedAIs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionAICell", for: indexPath) as! CollectionAICell
        cell.configure(with: collectedAIs[indexPath.item])
        
        // 添加长按手势
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let cell = gesture.view as? CollectionAICell,
                  let indexPath = collectionView.indexPath(for: cell) else {
                return
            }
            
            // 添加触感反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // 显示取消收藏确认框
            showUnfavoriteAlert(for: indexPath.item)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 12
        let totalPadding: CGFloat = padding * 3 // 左右边距和中间间距
        let availableWidth = collectionView.bounds.width - totalPadding
        let width = availableWidth / 2
        let height = width * 1.2
        return CGSize(width: width, height: height)
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ai = collectedAIs[indexPath.item]
        let detailVC = AIDetailViewController(ai: ai)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
} 
