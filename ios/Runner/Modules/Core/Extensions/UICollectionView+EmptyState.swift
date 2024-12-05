import UIKit

extension UICollectionView {
    func showEmptyState(with message: String) {
        let emptyView = EmptyStateView(title: message)
        backgroundView = emptyView
    }
    
    func hideEmptyState() {
        backgroundView = nil
    }
    
    func updateEmptyState(isEmpty: Bool, message: String) {
        if isEmpty {
            showEmptyState(with: message)
        } else {
            hideEmptyState()
        }
    }
} 