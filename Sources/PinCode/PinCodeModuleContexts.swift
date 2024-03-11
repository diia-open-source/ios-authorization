import UIKit
import DiiaAuthorization
import DiiaMVPModule

public struct EnterPinCodeModuleContext {
    let storage: PinCodeStorageProtocol
    let enterPinCodeDelegate: EnterPinCodeDelegate
    
    /**
     Context with dependencies for  the EnterPinCodeModule
     */
    public init(storage: PinCodeStorageProtocol,
                enterPinCodeDelegate: EnterPinCodeDelegate) {
        self.storage = storage
        self.enterPinCodeDelegate = enterPinCodeDelegate
    }
}

public struct ChangePincodeModuleContext {
    let storage: PinCodeStorageProtocol
    let pinCodeManager: PinCodeManagerProtocol
    let onOldPincodeWrongValue: (BaseView?) -> Void
    let onPincodeChangedWithSuccess: ([Int], BaseView?) -> Void
    
    /**
     Context with dependencies for  the ChangePincodeModule
     - parameter storage: storage that conforms protocol `PinCodeStorage`
     - parameter pinCodeManager: service that conforms protocol `PinCodeManagerProtocol`
     - parameter onOldPincodeWrongValue: app specific taks for case if user types wrong old pincode
     - parameter onPincodeChangedWithSuccess: app specific taks for case if used successfully confirmed old passcode and twice types new pincode
     */
    public init(storage: PinCodeStorageProtocol,
                pinCodeManager: PinCodeManagerProtocol,
                onOldPincodeWrongValue: @escaping (BaseView?) -> Void,
                onPincodeChangedWithSuccess: @escaping ([Int], BaseView?) -> Void) {
        self.storage = storage
        self.pinCodeManager = pinCodeManager
        self.onOldPincodeWrongValue = onOldPincodeWrongValue
        self.onPincodeChangedWithSuccess = onPincodeChangedWithSuccess
    }
}
