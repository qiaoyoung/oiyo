import UIKit
import SnapKit

class FeedbackViewController: UIViewController {
    
    private enum FeedbackType: Int, CaseIterable {
        case bug
        case suggestion
        case other
        
        var title: String {
            switch self {
            case .bug: return "Bug Report"
            case .suggestion: return "Suggestion"
            case .other: return "Other"
            }
        }
    }
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: FeedbackType.allCases.map { $0.title })
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = ColorManager.primary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: ColorManager.primary], for: .normal)
        return sc
    }()
    
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = ColorManager.textPrimary
        tv.backgroundColor = .systemBackground
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.delegate = self
        return tv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Please describe your issue or suggestion in detail..."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var contactTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contact information (optional)"
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = ColorManager.textPrimary
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 8
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupUI()
    }
    
    private func setupUI() {
        title = "Feedback"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Submit",
            style: .done,
            target: self,
            action: #selector(handleSubmit)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        view.addSubview(segmentedControl)
        view.addSubview(textView)
        view.addSubview(placeholderLabel)
        view.addSubview(contactTextField)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(textView).offset(16)
            make.leading.equalTo(textView).offset(12)
        }
        
        contactTextField.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }
    
    @objc private func handleSubmit() {
        guard let content = textView.text, !content.isEmpty else { return }
        
        let type = FeedbackType(rawValue: segmentedControl.selectedSegmentIndex) ?? .other
        let contact = contactTextField.text
        
        let alert = UIAlertController(
            title: "Submitted Successfully",
            message: "Thank you for your feedback, we will handle it carefully!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.isEmpty
    }
} 