import UIKit
import SnapKit

class PostMoodViewController: UIViewController {
    
    typealias CompletionHandler = (MoodPostModel) -> Void
    private let completion: CompletionHandler
    
    private let maxCharacterCount = 50
    
    // MARK: - UI Components
    private lazy var contentTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = ColorManager.textPrimary
        tv.backgroundColor = ColorManager.backgroundSecondary
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.delegate = self
        return tv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Share your mood..."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var moodSegmentedControl: UISegmentedControl = {
        let items = ["Happy", "Peaceful", "Sad", "Angry", "Anxious"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = ColorManager.primary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: ColorManager.primary], for: .normal)
        return sc
    }()
    
    
    
    // 添加字数提示标签
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorManager.textSecondary
        label.text = "0/\(maxCharacterCount)"
        return label
    }()
    
    // 添加成功反馈视图
    private lazy var successFeedbackView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.primary.withAlphaComponent(0.95)
        view.layer.cornerRadius = 20
        view.alpha = 0
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Posted successfully!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(24)
        }
        
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        return view
    }()
    
    // MARK: - Lifecycle
    init(completion: @escaping CompletionHandler) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        setupTapGesture()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = ColorManager.background
        title = "Post Mood"
        
        // 设置导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(handlePost)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // 添加子视图
        [contentTextView, placeholderLabel, moodSegmentedControl, characterCountLabel, successFeedbackView].forEach {
            view.addSubview($0)
        }
        
        // 设置约束
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextView).offset(12)
            make.leading.equalTo(contentTextView).offset(12)
        }
        
        characterCountLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(8)
            make.trailing.equalTo(contentTextView)
        }
        
        moodSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(characterCountLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        
        successFeedbackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(240)
        }
    }
    
    
    private func setupTapGesture() {
        // 添加点击手势来关闭键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        // 确保手势不会影响其他可点击的视图
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleBackgroundTap() {
        // 如果键盘正在显示，则收起键盘
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
    }
    
    // MARK: - Actions
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handlePost() {
        guard let contentStr = contentTextView.text,
              !contentStr.isEmpty,
              contentStr.count <= maxCharacterCount else {
            showAlert(message: contentTextView.text.isEmpty ? "Please enter your mood" : "Content exceeds character limit")
            return
        }
        
        let mood = MoodPostModel(id: "",
                             userId: "",
                             userAvatar: "",
                             userName: "",
                             content: contentStr,
                             mood: getMoodType(),
                             timestamp: Date(),
                             isMine: true)
        
        // 显示成功反馈
        showSuccessFeedback {
            self.completion(mood)
            self.dismiss(animated: true)
        }
    }
    
    private func getMoodType() -> MoodPostModel.MoodType {
        switch moodSegmentedControl.selectedSegmentIndex {
        case 0: return .happy
        case 1: return .peaceful
        case 2: return .sad
        case 3: return .angry
        case 4: return .anxious
        default: return .happy
        }
    }
    
    private func showSuccessFeedback(completion: @escaping () -> Void) {
        // 添加模糊背景
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 显示成功反馈
        view.bringSubviewToFront(successFeedbackView)
        UIView.animate(withDuration: 0.3, animations: {
            self.successFeedbackView.alpha = 1
            blurView.alpha = 0.3

        }) { _ in
            // 添加成功动画
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [1.0, 1.2, 1.0]
            animation.keyTimes = [0, 0.5, 1.0]
            animation.duration = 0.4
            self.successFeedbackView.layer.add(animation, forKey: "success")
            
            // 延迟消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.successFeedbackView.alpha = 0
                    blurView.alpha = 0
                }) { _ in
                    blurView.removeFromSuperview()
                    completion()
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard Handling
    @objc private func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        // 计算需要移动的距离，确保输入框不被键盘遮挡
        let textViewBottomY = contentTextView.convert(contentTextView.bounds, to: nil).maxY
        let keyboardTopY = view.bounds.height - keyboardHeight
        let offsetY = textViewBottomY - keyboardTopY + 20 // 额外添加20点的间距
        
        if offsetY > 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -offsetY)
            }
        }
    }
    
    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
}

// MARK: - UITextViewDelegate
extension PostMoodViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // 更新字数提示
        let count = textView.text.count
        characterCountLabel.text = "\(count)/\(maxCharacterCount)"
        
        // 超出字数限制时显示红色
        if count > maxCharacterCount {
            characterCountLabel.textColor = .systemRed
        } else {
            characterCountLabel.textColor = ColorManager.textSecondary
        }
        
        // 更新发布按钮状态
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.isEmpty && count <= maxCharacterCount
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 当开始编辑时，确保占位符正确显示
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 当结束编辑时，确保占位符正确显示
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // 处理return键
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 如果按下return键，收起键盘
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        // 检查字数限制
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxCharacterCount
    }
}

// MARK: - Keyboard Handling
extension PostMoodViewController {
    private func setupNotifications() {
        // 添加键盘通知观察
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // 添加应用进入后台的通知观察
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDidEnterBackground() {
        // 当应用进入后台时，收起键盘
        view.endEditing(true)
    }

} 
