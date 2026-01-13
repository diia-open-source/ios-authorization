
import UIKit
import DiiaMVPModule

struct ChangePincodeViewModel {
    let title: String
    let description: String
    let pinCodeLength: Int
    let checkAction: ([Int]) -> Bool
    let successAction: ([Int], BaseView?) -> Void
    let failureAction: (BaseView?) -> Void
}
