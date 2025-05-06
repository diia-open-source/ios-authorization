import Foundation
import DiiaMVPModule
import DiiaAuthorization
import DiiaCommonTypes

public class PinCodeViewModel {
    let pinCodeLength: Int
    let createDetails: String
    let repeatDetails: String
    let authFlow: AuthFlow
    let completionHandler: ([Int], BaseView) -> Void
    
    public init(
        pinCodeLength: Int,
        createDetails: String,
        repeatDetails: String,
        authFlow: AuthFlow,
        completionHandler: @escaping ([Int], BaseView) -> Void
    ) {
        self.pinCodeLength = pinCodeLength
        self.createDetails = createDetails
        self.repeatDetails = repeatDetails
        self.authFlow = authFlow
        self.completionHandler = completionHandler
    }
}
