import UIKit
import SnapKit

class AppIntroViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "app_icon")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Planet Station"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = ColorManager.textPrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your AI Assistant Platform"
        label.font = .systemFont(ofSize: 18)
        label.textColor = ColorManager.textSecondary
        return label
    }()
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorManager.textPrimary
        
        let text = """
        Planet Station is an innovative AI assistant platform dedicated to providing comprehensive intelligent dialogue services. We integrate professional AI assistants from multiple fields, including creative writing, technical consulting, and life planning, allowing each user to find the conversation partner that best suits their needs.

        At Planet Station, we understand that each user is a unique individual with different needs and expectations. Therefore, we have built a diverse AI assistant ecosystem where each AI assistant has its own personality traits and professional expertise, providing personalized communication experiences.

        Our AI assistants are not just simple Q&A tools, but your thinking partners. Whether in creative inspiration, technical problem solving, or daily life planning, they can provide professional, insightful advice and ideas. Through continuous dialogue and communication, AI assistants can better understand your needs and provide more accurate help.

        In terms of functionality, we pay special attention to user experience. The simple and intuitive interface design, smooth dialogue experience, and user-friendly feature configuration all reflect our pursuit of the ultimate user experience. Meanwhile, we also provide features like favorites and history records, making it convenient for users to review important conversation content at any time.

        Security and privacy are among our top concerns. We use advanced data encryption technology to ensure that all user conversation content is properly protected. At the same time, we promise never to use users' personal information for any unauthorized purposes.

        Planet Station is not just a product, but an evolving platform. We continuously monitor user feedback, constantly optimize and update AI models to provide better services. We look forward to growing with every user and exploring the infinite possibilities brought by AI together.
        """
        
        label.text = text
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "APP简介"
        view.backgroundColor = .systemBackground
        setupCustomBackButton()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [headerImageView, titleLabel, subtitleLabel, introLabel].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        headerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
        }
        
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
} 
