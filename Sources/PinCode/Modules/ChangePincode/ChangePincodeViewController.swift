import UIKit
import DiiaMVPModule
import DiiaUIComponents

protocol ChangePincodeView: BaseView {
    func configure(with pinCodeLength: Int)
    func setTitle(title: String)
    func setDescription(description: String)
    func userDidEnterIncorrectPin()
    func setEnteredNumbersCount(count: Int)
}

final class ChangePincodeViewController: UIViewController, Storyboarded {

	// MARK: - Outlets
    @IBOutlet private weak var pincodeView: PincodeView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet weak private var pincodeHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var presenter: ChangePincodeAction!
    
	// MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.font = FontBook.detailsTitleFont
        infoLabel.font = FontBook.usualFont
        pincodeHeightConstraint.constant = Constants.pincodeHeight
        pincodeView.delegate = self
        presenter.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.clear()
    }
    
    // MARK: - Private Methods
    @IBAction private func backButtonPressed(_ sender: UIButton) {
        closeModule(animated: true)
    }
}

// MARK: - View logic
extension ChangePincodeViewController: ChangePincodeView {
    func configure(with pinCodeLength: Int) {
        pincodeView.indicatorsAmount = pinCodeLength
    }
    
    func setTitle(title: String) {
        headerLabel.text = title
    }
    
    func setDescription(description: String) {
        infoLabel.text = description
    }
    
    func userDidEnterIncorrectPin() {
        pincodeView.notifyIncorrectPincode()
    }
    
    func setEnteredNumbersCount(count: Int) {
        pincodeView.setNumbersCount(count: count)
    }
}

// MARK: - PinCodeViewDelegate
extension ChangePincodeViewController: PinCodeViewDelegate {
    func numberSelected(number: Int) {
        presenter.selectNumber(number: number)
    }
    
    func clearPressed() {
        presenter.removeLast()
    }
}

// MARK: - Constants
extension ChangePincodeViewController {
    private enum Constants {
        static var pincodeHeight: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch, .screen_zoomed: return 372
            case .screen5_5Inch, .screen6_1Inch: return 480
            case .screen6_5Inch, .screen6_7Inch: return 640
            default: return 436
            }
        }
    }
}
