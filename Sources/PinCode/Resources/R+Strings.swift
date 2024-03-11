import Foundation

internal extension R {
    enum Strings: String, CaseIterable {

        // MARK: - Accessibility
        case auth_accessibility_pincode_clear_button_label
        case general_accessibility_back_button_label
        case general_accessibility_back_button_hint
        case auth_accessibility_pincode_header_hint
        case general_accessibility_back_button_step
        case auth_accessibility_biometry_request_approve
        case auth_accessibility_biometry_request_later
        
        // MARK: - General
        case general_step
        
        // MARK: - Authorization
        case authorization_create_pincode
        case authorization_repeat_pincode
        case authorization_allow
        case authorization_allow_later
        case authorization_new_pin_details
        case authorization_repeat_pin_details
        
        // MARK: - Menu
        case menu_change_pin_new
        case menu_change_pin_olddescr
        case menu_change_pin_repeat
        
        func localized() -> String {
            let localized = NSLocalizedString(rawValue, bundle: Bundle.module, comment: "")
            return localized
        }
        
        func formattedLocalized(arguments: CVarArg...) -> String {
            let localized = NSLocalizedString(rawValue, bundle: Bundle.module, comment: "")
            return String(format: localized, arguments)
        }
    }
}
