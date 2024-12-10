import UIKit
import SnapKit

class MyAIViewController: UIViewController {
    
    private var myAIs: [AIUserModel] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(MyAICell.self, forCellWithReuseIdentifier: "MyAICell")
        return cv
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(named: "empty_ai"))
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "还没有收藏任何AI助手"
        label.textColor = ColorManager.textSecondary
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        
        let button = UIButton(type: .system)
        button.setTitle("去发现AI", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ColorManager.primary
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(handleExplore), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(120)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        return view
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
        title = "我的AI助手"
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(emptyView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadData() {
        // 从本地加载收藏的AI
        if let favoriteAIIds = UserDefaults.standard.array(forKey: "FavoriteAIs") as? [String]{
            myAIs = AIUserDataManager.shared.aiUsers.filter { favoriteAIIds.contains($0.id) }
            updateUI()
        }
    }
    
    private func updateUI() {
        collectionView.updateEmptyState(
            isEmpty: myAIs.isEmpty,
            message: "还没有收藏任何AI助手"
        )
        collectionView.reloadData()
    }
    
    @objc private func handleExplore() {
        // 切换到AI广场tab
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 0 // 假设AI广场是第一个tab
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MyAIViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myAIs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyAICell", for: indexPath) as! MyAICell
        cell.configure(with: myAIs[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyAIViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: width * 1.3)
    }
}

// MARK: - UICollectionViewDelegate
extension MyAIViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ai = myAIs[indexPath.item]
        let detailVC = AIDetailViewController(ai: ai)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
} 
