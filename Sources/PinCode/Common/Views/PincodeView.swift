
import UIKit
import DiiaUIComponents
import DiiaCommonTypes

protocol PinCodeViewDelegate: NSObjectProtocol {
    func numberSelected(number: Int)
    func clearPressed()
}

final class PincodeView: UIView {

    // MARK: - Outlets
    
    @IBOutlet weak private var indicatorsStack: UIStackView!
    
    @IBOutlet weak private var buttonsVerticalStack: UIStackView!
    @IBOutlet private var buttonsHorizontalStacks: [UIStackView]!
    
    @IBOutlet weak private var clearButton: UIButton!
    @IBOutlet weak private var biometryButton: UIButton!
    
    @IBOutlet private var digitButtons: [VerticalRoundButton]!
    
    // MARK: - Constraints
    @IBOutlet weak private var indicatorsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var buttonsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var buttonsBottompConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    weak var delegate: PinCodeViewDelegate?
    private var additionalAction: Callback?
    
    var indicatorsAmount = Constants.defaultIndicatorsAmount {
        didSet {
            prepareIndicators()
        }
    }
    private var indicators: [UIView] = []
    
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        fromNib(bundle: Bundle.module)
        prepareIndicators()
    }
    
    private func prepareIndicators() {
        indicators.forEach {
            self.indicatorsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        indicators.removeAll()
        
        (0..<indicatorsAmount)
            .map { _ -> UIView in
                let indicator = UIView()
                
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.widthAnchor.constraint(equalToConstant: Constants.indicatorSize).isActive = true
                indicator.heightAnchor.constraint(equalToConstant: Constants.indicatorSize).isActive = true
                indicator.layer.cornerRadius = Constants.indicatorSize / 2
                indicator.backgroundColor = .white
                self.indicators.append(indicator)
                
                return indicator
            }
            .forEach { indicatorsStack.addArrangedSubview($0) }
    }
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    private func initialSetup() {
        backgroundColor = .clear
        setupConstraints()
        setupButtons()
        setupAccessibility()
    }
    
    private func setupButtons() {
        digitButtons.forEach {
            $0.clipsToBounds = true
            $0.titleLabel?.font = FontBook.pincodeDigitFont
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.white, for: .highlighted)
            $0.setBackgroundColor(.white, for: .normal)
            $0.setBackgroundColor(.black, for: .highlighted)
            $0.addTarget(self, action: #selector(numberPressed), for: .touchUpInside)
            $0.accessibilityIdentifier = Constants.accessibilityId(for: $0.tag)
        }
        
        let clearImage = R.Image.removeNum.image
        let higlightedClearImage = clearImage?.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(clearImage, for: .normal)
        clearButton.setImage(higlightedClearImage, for: .highlighted)
    }
    
    private func setupConstraints() {
        buttonsVerticalStack.spacing = Constants.verticalInteritemSpacing
        buttonsHorizontalStacks.forEach { $0.spacing = Constants.horizontalInteritemSpacing }
        indicatorsStack.spacing = Constants.indicatorsInteritemSpacing
        indicatorsTopConstraint.constant = Constants.indicatorsTopOffset
        buttonsTopConstraint.constant = Constants.buttonsTopOffset
        buttonsBottompConstraint.constant = Constants.buttonsBottomOffset
    }
    
    private func setupAccessibility() {
        biometryButton.isAccessibilityElement = false
        clearButton.accessibilityLabel = R.Strings.auth_accessibility_pincode_clear_button_label.localized()
    }
    
    // MARK: - Public Methods
    func setIndicatorsAmount(_ amount: Int) {
        indicatorsAmount = amount
        prepareIndicators()
    }
    
    func configureAdditionalButton(image: UIImage?, action: @escaping Callback) {
        additionalAction = action
        
        let higlightedImage = image?.withRenderingMode(.alwaysTemplate)
        biometryButton.setImage(image, for: .normal)
        biometryButton.setImage(higlightedImage, for: .highlighted)
        
        biometryButton.isAccessibilityElement = true
    }
    
    func setNumbersCount(count: Int) {
        guard count <= indicators.count else { return }
        
        indicators
            .enumerated()
            .forEach { (index, indicator) in
                indicator.backgroundColor = count > index ? .black : .white
            }
    }
    
    func notifyIncorrectPincode() {        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = Constants.animationDuration
        animation.values = [-20.0, 20.0, -15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        indicatorsStack.layer.add(animation, forKey: "shake")
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        
        onMainQueueAfter(time: Constants.voiceOverAnnouncementDelay) {
            UIAccessibility.post(notification: .announcement, argument: R.Strings.general_accessibility_incorrect_password.localized())
        }
    }
    
    func setComponentIds(indicatorsId: String, buttonsTile: String) {
        indicatorsStack.accessibilityIdentifier = indicatorsId
        buttonsVerticalStack.accessibilityIdentifier = buttonsTile
    }

    // MARK: - Actions
    @IBAction private func clearPressed(_ sender: Any) {
        delegate?.clearPressed()
    }
    
    @objc private func numberPressed(_ sender: UIButton) {
        let number = sender.tag
        delegate?.numberSelected(number: number)
    }
    
    @IBAction private func additionalButtonPressed(_ sender: Any) {
        additionalAction?()
    }
}

// MARK: - Constants
extension PincodeView {
    private enum Constants {
        static let defaultIndicatorsAmount = 4
        static let indicatorBorderWidth: CGFloat = 2
        static let digitButtonBorderWidth: CGFloat = 2
        static let animationDuration: TimeInterval = 0.6
        static let voiceOverAnnouncementDelay: TimeInterval = 0.1
        
        static var indicatorSize: CGFloat = 11
        static var indicatorsInteritemSpacing: CGFloat = 8
        static var horizontalInteritemSpacing: CGFloat = 32
        static var verticalInteritemSpacing: CGFloat = 16
        
        static var indicatorsTopOffset: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch, .screen_zoomed: return 17
            case .screen5_5Inch, .screen6_1Inch: return 22
            case .screen6_5Inch, .screen6_7Inch: return 97
            default: return 20
            }
        }
        
        static var buttonsTopOffset: CGFloat {
            switch UIDevice.size() {
            case .screen6_5Inch, .screen6_7Inch: return 40
            default: return 24
            }
        }
        
        static var buttonsBottomOffset: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch, .screen_zoomed: return 26
            case .screen5_5Inch, .screen6_1Inch: return 30
            case .screen6_5Inch, .screen6_7Inch: return 115
            default: return 28
            }
        }

        static func accessibilityId(for number: Int) -> String {
            return "btn_num_\(number)"
        }
    }
}
