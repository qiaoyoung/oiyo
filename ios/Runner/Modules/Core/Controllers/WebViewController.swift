import UIKit
import WebKit
import SnapKit

class WebViewController: UIViewController {
    
    private let urlString: String
    private let pageTitle: String
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = ColorManager.primary
        progress.trackTintColor = .clear
        return progress
    }()
    
    init(url: String, title: String) {
        self.urlString = url
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebContent()
        
        // 添加进度监听
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            
            // 当加载完成时，渐隐进度条
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.progress = 0
                })
            } else {
                progressView.alpha = 1
            }
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    private func setupUI() {
        title = pageTitle
        view.backgroundColor = .white
        setupCustomBackButton()
        
        view.addSubview(webView)
        view.addSubview(progressView)
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    private func loadWebContent() {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.progress = 0
        progressView.alpha = 1
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.progress = 1
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            self.progressView.alpha = 0
        }, completion: { _ in
            self.progressView.progress = 0
        })
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.progress = 0
        progressView.alpha = 0
    }
} 