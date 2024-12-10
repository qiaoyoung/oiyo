import UIKit

extension UITableView {
    func showEmptyState(with message: String) {
        let emptyView = EmptyStateView(title: message)
        backgroundView = emptyView
        separatorStyle = .none
    }
    
    func hideEmptyState() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
    
    func updateEmptyState(isEmpty: Bool, message: String) {
        if isEmpty {
            showEmptyState(with: message)
        } else {
            hideEmptyState()
        }
    }
} 