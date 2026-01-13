
import Foundation

public struct EnterPinCodeViewModel {
    let pinCodeLength: Int
    let title: String
    let forgotTitle: String
    
    public init(pinCodeLength: Int, title: String, forgotTitle: String) {
        self.pinCodeLength = pinCodeLength
        self.title = title
        self.forgotTitle = forgotTitle
    }
}
