import UIKit
import WebKit

class TermsViewController: UIViewController {
    enum TermsType {
        case autoRenew
        case eula
        
        var title: String {
            switch self {
            case .autoRenew: return "Auto-Renewal Agreement"
            case .eula: return "Terms of Service"
            }
        }
        
        var fileName: String {
            switch self {
            case .autoRenew: return "auto_renew_terms"
            case .eula: return "eula_terms"
            }
        }
    }
    
    private let termsType: TermsType
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    
    init(type: TermsType) {
        self.termsType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTerms()
    }
    
    private func setupUI() {
        title = termsType.title
        view.backgroundColor = .systemBackground
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        setupCustomBackButton()

    }
    
    private func loadTerms() {
        if let path = Bundle.main.path(forResource: termsType.fileName, ofType: "html"),
           let htmlString = try? String(contentsOfFile: path, encoding: .utf8) {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
}

// MARK: - WKNavigationDelegate
extension TermsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
} 
