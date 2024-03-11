import UIKit

// internal because we are not ready to expose this API to outer modules yet
internal enum R {
    enum Image: String, CaseIterable {
        case clear
        case menu_back
        case fingerprint
        case faceId
        case light_background
        case removeNum
        
        var image: UIImage? {
            return UIImage(named: rawValue, in: Bundle.module, compatibleWith: nil)
        }
        
        var name: String {
            return rawValue
        }
    }
}
