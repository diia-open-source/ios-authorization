
import UIKit

internal extension R {
    enum Image: String, CaseIterable {
        
        case loadingBar
        case menu_back
        case out_link
        case light_background
        
        var image: UIImage? {
            return UIImage(named: rawValue, in: Bundle.module, compatibleWith: nil)
        }
        
        var name: String {
            return rawValue
        }
    }
}
