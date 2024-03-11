import UIKit

internal enum R {
    enum Image: String, CaseIterable {
        case clear
        case photoId_squared
        case nfc_icon_squared
        case bankId_icon_squared
        case monobank
        case privat24
        case loadingBar
        case diia_icon
        case tryzub_icon
        case light_background
        
        var image: UIImage? {
            return UIImage(named: rawValue, in: Bundle.module, compatibleWith: nil)
        }
        
        var name: String {
            return rawValue
        }
    }
}
