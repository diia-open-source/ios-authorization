import Foundation

public enum DiiaIdAction: String {
    case creation
    case signing
}

// MARK: - AuthFlow
/// Used for UI customization
public enum AuthFlow {
    case login
    case serviceLogin
    case prolong
    case diiaId(action: DiiaIdAction)
    case residencePermitNfcAdding
}
