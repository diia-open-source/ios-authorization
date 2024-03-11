import UIKit
import WebKit
import DiiaMVPModule
import DiiaUIComponents

protocol BankIdAuthView: BaseView {
    func load(url: URL)
    func showInsecureContentInfo()
}

final class BankIdAuthViewController: UIViewController, Storyboarded {

    // MARK: - Outlets
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var webContainer: UIView!
	
    // MARK: - Properties
	var presenter: BankIdAuthAction!

    private lazy var webView: WKWebView = {
        let webViewConfig = createWebViewConfig()
        let webView = WKWebView(frame: view.bounds, configuration: webViewConfig)
        
        return webView
    }()
    
	// MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAccessibility()
        setupWebView()
        presenter.configureView()
    }
    
    private func setupWebView() {
        webContainer.addSubview(webView)
        webView.navigationDelegate = self
        webView.fillSuperview()
        webView.allowsLinkPreview = false
    }
    
    private func createWebViewConfig() -> WKWebViewConfiguration {
        let webPreferences = WKPreferences()
        webPreferences.javaScriptEnabled = true
        webPreferences.javaScriptCanOpenWindowsAutomatically = false
        
        let contentController = WKUserContentController()
        let removeLocationJS = """
        navigator.geolocation.getCurrentPosition = function(success, error, options) {};
        navigator.geolocation.watchPosition = function(success, error, options) {};
        navigator.geolocation.clearWatch = function(id) {};
        """
        let script = WKUserScript(source: removeLocationJS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)
        
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.preferences = webPreferences
        wkWebConfig.userContentController = contentController
        
        return wkWebConfig
    }
    
    private func setupAccessibility() {
        backButton.accessibilityLabel = R.Strings.general_accessibility_back_button_label.localized()
        backButton.accessibilityHint = R.Strings.general_accessibility_back_button_step.localized()
    }
    
    // MARK: - Actions
    @IBAction private func backBtnPressed(_ sender: Any) {
        self.closeModule(animated: true)
    }
}

// MARK: - View logic
extension BankIdAuthViewController: BankIdAuthView {
    func load(url: URL) {
        var request = URLRequest(url: url)
        request.addValue(Constants.header(with: presenter.appShortVersion), forHTTPHeaderField: Constants.headerField)
        webView.load(request)
    }
    
    func showInsecureContentInfo() {
        let alertAction = AlertAction(title: R.Strings.general_ok.localized(),
                                      type: .normal,
                                      callback: { [weak self] in
                                            self?.closeToRoot()
                                    })
        let module = CustomAlertModule(title: R.Strings.authorization_bank_id_insecure_title.localized(),
                                       message: R.Strings.authorization_bank_id_insecure_description.localized(),
                                       actions: [alertAction])
        self.showChild(module: module)
    }
}

// MARK: - WKNavigationDelegate
extension BankIdAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, presenter.handle(url: url) {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !webView.hasOnlySecureContent {
            log("Unsecure content in web view. Closing the module")
            presenter.handleUnsecureContent()
        }
    }
}

private extension BankIdAuthViewController {
    enum Constants {
        static let headerField = "x-diia-version"
        static func header(with appShortVersion: String) -> String {
            "iOS:\(appShortVersion)"
        }
    }
}
