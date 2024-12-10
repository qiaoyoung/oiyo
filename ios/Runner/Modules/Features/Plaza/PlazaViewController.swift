import UIKit
import SnapKit
import MJRefresh

class PlazaViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Properties
    private var categories: [AIUserCategory] = []
    private var filteredCategories: [AIUserCategory] = []
    private var currentFilter: AIFilter = .all
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HorizontalCategoryCell.self, forCellWithReuseIdentifier: "HorizontalCategoryCell")
        collectionView.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "CategoryHeaderView"
        )
        
        collectionView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .appPrimary
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadData()
        navigationItem.title = ""
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupNavigationBar() {
        let filterBarButton = UIBarButtonItem(customView: filterButton)
        navigationItem.rightBarButtonItem = filterBarButton
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Data Loading
    private func loadData() {
        categories = AIUserDataManager.shared.groupedAIUsers
        shuffleAllCategories()
        filteredCategories = categories
        collectionView.reloadData()
    }
    
    @objc private func refreshData() {
        shuffleAllCategories()
        filteredCategories = categories
        collectionView.reloadData()
        collectionView.mj_header?.endRefreshing()
    }
    
    private func shuffleAllCategories() {
        categories = categories.map { category in
            var shuffledCategory = category
            shuffledCategory.users = category.users.shuffled()
            return shuffledCategory
        }
    }
    
    // MARK: - Navigation
    private func showCategoryDetail(_ category: AIUserCategory) {
        let detailVC = AIUserListViewController(category: category)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PlazaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = filteredCategories[indexPath.section]
        let width = collectionView.bounds.width
        
        // 计算该分类下所有卡片中的最大高度
        let maxHeight = calculateMaxCardHeight(for: category.users)
        
        return CGSize(width: width, height: maxHeight + 20) // 添加一些额外的边距
    }
    
    private func calculateMaxCardHeight(for users: [AIUserModel]) -> CGFloat {
        let cellWidth = (UIScreen.main.bounds.width - 52) / 2 // 考虑边距
        
        // 计算每个用户卡片的高度，找出最大值
        let heights = users.map { user -> CGFloat in
            // 计算图片高度
            let imageHeight: CGFloat
            if let image = UIImage(named: user.avatar) {
                let ratio = image.size.height / image.size.width
                imageHeight = cellWidth * ratio
            } else {
                imageHeight = cellWidth
            }
            
            // 计算文本高度
            let maxWidth = cellWidth - 12 // 考虑内边距
            let titleHeight = user.nickname.height(withConstrainedWidth: maxWidth, font: .systemFont(ofSize: 14, weight: .medium))
            let signatureHeight = user.signature.height(withConstrainedWidth: maxWidth, font: .systemFont(ofSize: 12), numberOfLines: 2)
            
            // 总高度（包含间距）
            return imageHeight + titleHeight + signatureHeight + 16
        }
        
        return heights.max() ?? 200 // 如果没有数据，使用默认高度
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
}

// MARK: - String Extension
private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont, numberOfLines: Int = 1) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let height = ceil(boundingBox.height)
        return numberOfLines > 0 ? min(height, font.lineHeight * CGFloat(numberOfLines)) : height
    }
}

// MARK: - UICollectionViewDataSource
extension PlazaViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // 每个分组只有一个水平滚动的cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCategoryCell", for: indexPath) as? HorizontalCategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = filteredCategories[indexPath.section]
        cell.delegate = self // 设置代理
        cell.configure(with: category.users)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "CategoryHeaderView",
                for: indexPath
              ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        let category = filteredCategories[indexPath.section]
        header.configure(with: category.title) { [weak self] in
            self?.showCategoryDetail(category)
        }
        return header
    }
}

// MARK: - HorizontalCategoryCellDelegate
extension PlazaViewController: HorizontalCategoryCellDelegate {
    func horizontalCategoryCell(_ cell: HorizontalCategoryCell, didSelectUser user: AIUserModel) {
        let detailVC = AIDetailViewController(ai: user)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Filter Related
extension PlazaViewController {
    @objc private func filterButtonTapped() {
        let alertController = UIAlertController(
            title: "Filter",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        AIFilter.allCases.forEach { filter in
            let action = UIAlertAction(title: filter.title, style: .default) { [weak self] _ in
                self?.applyFilter(filter)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func applyFilter(_ filter: AIFilter) {
        currentFilter = filter
        
        switch filter {
        case .all:
            filteredCategories = categories
        case .companion:
            filterByType("companion")
        case .creative:
            filterByType("creative")
        case .education:
            filterByType("education")
        case .assistant:
            filterByType("assistant")
        case .highRating:
            filterByRating(4.8)
        }
        
        collectionView.reloadData()
    }
    
    private func filterByType(_ type: String) {
        filteredCategories = categories.compactMap { category in
            let filteredUsers = category.users.filter { $0.aiType == type }
            return filteredUsers.isEmpty ? nil : AIUserCategory(title: category.title, users: filteredUsers)
        }
    }
    
    private func filterByRating(_ minRating: Double) {
        filteredCategories = categories.compactMap { category in
            let filteredUsers = category.users.filter { $0.rating >= minRating }
            return filteredUsers.isEmpty ? nil : AIUserCategory(title: category.title, users: filteredUsers)
        }
    }
}

// MARK: - Filter Enum
private enum AIFilter: CaseIterable {
    case all
    case companion
    case creative
    case education
    case assistant
    case highRating
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .companion:
            return "Companion"
        case .creative:
            return "Creative"
        case .education:
            return "Education"
        case .assistant:
            return "Assistant"
        case .highRating:
            return "High Rating(≥4.8)"
        }
    }
}
