import UIKit

class AIImageViewerController: UIViewController {
    
    // MARK: - Properties
    private let image: UIImage?
    private var initialTouchPoint: CGPoint = .zero
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.8
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.down.circle.fill"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.8
        return button
    }()
    
    // MARK: - Initialization
    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        
        imageView.image = image
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(44)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(44)
        }
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let image = image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let point = gesture.location(in: imageView)
            let size = CGSize(width: scrollView.bounds.size.width / 2.0, height: scrollView.bounds.size.height / 2.0)
            let origin = CGPoint(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0)
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            let translation = CGPoint(
                x: touchPoint.x - initialTouchPoint.x,
                y: touchPoint.y - initialTouchPoint.y
            )
            updateViewsForTranslation(translation)
        case .ended, .cancelled:
            let translation = CGPoint(
                x: touchPoint.x - initialTouchPoint.x,
                y: touchPoint.y - initialTouchPoint.y
            )
            handleEndedPanGesture(translation)
        default:
            break
        }
    }
    
    private func updateViewsForTranslation(_ translation: CGPoint) {
        let percentage = abs(translation.y) / view.bounds.height
        view.transform = CGAffineTransform(translationX: 0, y: translation.y)
        view.alpha = 1 - percentage
    }
    
    private func handleEndedPanGesture(_ translation: CGPoint) {
        let percentage = abs(translation.y) / view.bounds.height
        
        if percentage > 0.3 {
            dismiss(animated: true)
        } else {
            UIView.animate(withDuration: 0.2) {
                self.view.transform = .identity
                self.view.alpha = 1.0
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Show error alert
            let alert = UIAlertController(
                title: "Save Failed",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            // Show success alert
            let alert = UIAlertController(
                title: "Save Successful",
                message: "Image saved to Photos",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension AIImageViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let conditionLeft = newWidth*scrollView.zoomScale > scrollView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - scrollView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                
                let conditionTop = newHeight*scrollView.zoomScale > scrollView.frame.height
                let top = 0.5 * (conditionTop ? newHeight - scrollView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
} 