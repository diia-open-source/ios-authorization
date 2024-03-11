# DiiaAuthorization

Authorization core functionality and Bank-ID auth method. PinCode functionality: creating, entering, changing pincode plus enabling the using biometry option

## Description

- Authorization core is presented by `VerificationService` and `AuthorizationService`, they are handler managers for setting up the authorization process
- Bank-ID authorization method is presented by `SelectBankModule`
- PinCode functionality is represented by pin code operations such as `CreatePinCodeModule`(create), `EnterPinCodeModule`(enter), `ChangePincodeModule`(change) and `BiometryRequestModule`(biometric request) if possible

## Useful Links

|Topic|Link|Description|
|--|--|--|
|Ministry of Digital Transformation of Ukraine|https://thedigital.gov.ua/|The Official homepage of the Ministry of Digital Transformation of Ukraine| 
|Diia App|https://diia.gov.ua/|The Official website for the Diia application

## Getting Started 

### Installing

To install DiiaAuthorization using [Swift Package Manager](https://github.com/apple/swift-package-manager) you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for this repo with the current version:

1. In Xcode, select “File” → “Add Packages...”
1. Enter `https://github.com/diia-open-source/ios-authorization.git`

or you can add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/diia-open-source/ios-authorization.git", from: "1.0.0")
```

## Usage

### `VerificationService`

The main verification handler service for `DiiaAuthorization` that depends on `AuthorizationService`.

```swift
import DiiaAuthorization

let authService: AuthorizationServiceProtocol = AuthorizationService(authorizationService: AuthorizationContext.create())
let network: AuthorizationNetworkContext = .create()
let userIdentifyHandlers: [AuthMethod: IdentifyTaskPerformer] = .userIdentifyHandlers

let verificationService: VerificationService  = .init(authorizationService: authService,
                                                      network: network,
                                                      userIdentifyHandlers: userIdentifyHandlers)
                                                                                            

private extension Dictionary {
    // Returns a specific identity task based on the auth method key, providing instructions to the AuthMethodsHandler on how to handle its auth flow when called
    static var userIdentifyHandlers: [AuthMethod: IdentifyTaskPerformer] {
        AuthMethod.allCases.reduce(into: [:]) { result, authMethod in
            switch authMethod {
            case .bankId:
                result[authMethod] = BankIDIdentifyTask()
            default: return
            }
        }
    }
}
```

### `SelectBankModule`

Entry point for `DiiaAuthorizationMethods.BankIDAuthMethod` that depends on `BankIDAuthorizationContext`.
It should be called in `BankIDIdentifyTask` that conforms to `IdentifyTaskPerformer` and is required for the dictionary above.

```swift
import DiiaAuthorization
import DiiaAuthorizationMethods

final class BankIDIdentifyTask: IdentifyTaskPerformer {
    
    func identify(with input: UserIdentificationInput) {
        // Retreive a view as BaseView from UserIdentificationInput instance
        guard let view = input.initialView else { return }
        
        let context: BankIDAuthorizationContext = .create()
        let onClose: ((AlertTemplateAction) -> Void) = input.onCloseCallback
        // Define base redirection hosts are available for handling by the authorization flow
        let handledRedirectionHosts = ["api2oss.diia.gov.ua"]
        // Retrieve the value of CFBundleShortVersionString as a String
        let appShortVersion = "1.0.0"
        
        let module = SelectBankModule(context: context,
                                      onClose: onClose,
                                      handledRedirectionHosts: handledRedirectionHosts,
                                      appShortVersion: appShortVersion)
        
        view.open(module: module)
    }
}
```

### `AuthorizationService`

The main authentication handler service for `DiiaAuthorization` that depends on `AuthorizationContext`.

```swift
import DiiaNetwork
import DiiaAuthorization

extension AuthorizationContext {
    // Dependencies in the context should be defined or confirmed at the project level as shown in the example.
    static func create() -> AuthorizationContext {
        let network: AuthorizationNetworkContext = .create()
        let storage: AuthorizationStorageProtocol = AuthorizationStorage(storage: StoreHelper.instance)
        let serviceAuthSuccessModule: BaseModule? = nil 
        let refreshTemplateActionProvider: RefreshTemplateActionProvider = RefreshTemplateActionProviderImpl()
        let authStateHandler: AuthorizationServiceStateHandler = AuthorizationStateHandler(appRouter: AppRouter.instance, storage: StoreHelper.instance)
        let userAuthorizationErrorRouter: RouterExtendedProtocol = UserAuthorizationErrorRouter()
        let analyticsHandler: AnalyticsAuthorizationHandler = AnalyticsAuthorizationAdapter()
        
        return .init(network: network,
                     storage: storage,
                     serviceAuthSuccessModule: serviceAuthSuccessModule,
                     refreshTemplateActionProvider: refreshTemplateActionProvider,
                     authStateHandler: authStateHandler,
                     userAuthorizationErrorRouter: userAuthorizationErrorRouter,
                     analyticsHandler: analyticsHandler)
    }
}

extension AuthorizationNetworkContext {
    static func create() -> AuthorizationNetworkContext {
        // Retrieve preconfigured `session without interceptor` from DiiaNetwork.NetworkConfiguration
        let session = NetworkConfiguration.default.sessionWithoutInterceptor
        let host = "localhost:443"
        // Define base headers for authorization API endpoint
        let headers = ["App-Version": "1.0.0",
                       "User-Agent": "user-agent-value"]
                       
        return .init(session: session,
                     host: host,
                     headers: headers)
    }
}

let authService: AuthorizationService = .init(context: .create())
```

### Usage of `VerificationService` and `AuthorizationService` for passing authorization

```swift
// Get and display auth methods for selection, then verify authentication via the chosen approach using VerificationService
func showLoginAuthMethods() {
    verificationService.verifyUser(for: VerificationFlow.authorization, in: view) { [weak self] result in
        guard let self = self else { return }
        
        switch result {
        case .success(let processId):
            self.login(processId: processId)
        case .canceled:
            self.view.closeToView(view: self.view, animated: true)
        case .failure, .close:
            break
        }
    }
}

// Log in to the app by obtaining a token using AuthorizationService after successfully verifying the user
func login(processId: String) {
    authService.userLogin(in: view, processId: processId) { [weak self] error in
        if error == nil {
            // After successfully saving the token, it is possible to start the process of creating a pin code via CreatePinCodeModule
            self?.createPincode()
        }
    }
} 
```

### `DiiaAuthorizationPinCode`

The `DiiaAuthorizationPinCode` package handles key pincode operations such as create, enter, repeat, change and biometric request if possible.

- `CreatePinCodeModule`: _Provides the ability to display a configurable pincode creation flow with an encapsulated retry module inside_

```swift
func createPincode() {
    let pinCodeLength = 4
    let createDetails = "Custom details in CreatePinCodeView"
    let repeatDetails = "Custom details in RepeatPinCodeView"
    let authFlow: AuthFlow = .login
    
    // Configurable viewModel for public CreatePinCodeModule and internal RepeatPinCodeModule
    let viewModel = PinCodeViewModel(pinCodeLength: pinCodeLength,
                                     createDetails: createDetails,
                                     repeatDetails: repeatDetails,
                                     authFlow: authFlow,
                                     completionHandler: { pincode, view in
        authService.setPincode(pincode: pincode)
        // Display a screen prompting for permission to enable biometric login if available (Touch ID or Face ID).
        // Otherwise, show the entry point for the main app flow.
        switch BiometryHelper.biometricType() {
        case .none:
            AppRouter.instance.open(module: MainTabBarModule(), needPincode: false, asRoot: true)
            AppRouter.instance.didFinishStartingWithPincode = true
        default:
            StoreHelper.instance.save(false, type: Bool.self, forKey: .isBiometryEnabled)
            view.open(module: BiometryRequestModule(viewModel: .default(authFlow: .login)))
        }
    })
    
    let createPincodeModule = CreatePinCodeModule(viewModel: viewModel)
    view.open(module: createPincodeModule)
}
```

- `BiometryRequestModule`: _Provides a screen requesting permission to enable biometric login, if supported (Touch ID or Face ID)_

```swift
func createBiometryRequest() {
    let title = biometryType == .faceID ? "Allow Face ID" : "Allow Touch ID"
    let description = biometryType == .faceID ? "Custom details about Face ID" : "Custom details about Touch ID"
    let icon = biometryType == .faceID ? Resources.images.faceID : Resources.images.touchID
    let authFlow: AuthFlow = .login
    
    
    // Configurable viewModel for public BiometryRequestModule
    let viewModel = BiometryRequestViewModel(title: title,
                                             description: description,
                                             icon: icon,
                                             authFlow: authFlow,
                                             completionHandler: { isAllowed, biometryView in
        StoreHelper.instance.save(isAllowed, type: Bool.self, forKey: .isBiometryEnabled)
        
        switch authService.authState {
        case .userAuth:
            AppRouter.instance.open(module: MainTabBarModule(), needPincode: false, asRoot: true)
            AppRouter.instance.didFinishStartingWithPincode = true
        case .notAuthorized, .serviceAuth:
            break
        }
    }
    )
    
    let biometryRequestModule = BiometryRequestModule(viewModel: viewModel)
    view.open(module: biometryRequestModule)
}
```

- `EnterPinCodeModule`: _Provides the ability to enter created pincode to verify the user. If entered incorrectly three times, prompts to force reauthorization_

```swift
func enterPincode(completion: @escaping (Result<String, Error>) -> Void) {
    let pinCodeLength = 4
    let title = "Custom title in EnterPinCodeView"
    let forgotTitle = "Custom title in reauth alert"
    
    // Configurable viewModel for public BiometryRequestModule
    let viewModel = EnterPinCodeViewModel(pinCodeLength: pinCodeLength,
                                          title: title,
                                          forgotTitle: forgotTitle)
    let authFlow: EnterPinCodeFlow = .auth
    // Set a completion for a specific flow after a successful pin code entry
    let context = EnterPinCodeModuleContext.create(flow: .auth, completionHandler: completion)
    
    // Display the module as a pushed view controller
    let enterPincodeModule = EnterPinCodeModule(context: context,
                                                flow: authFlow,
                                                viewModel: viewModel)
    view.open(module: enterPincodeModule)
    
    //...
    // Or it's possible to display the module as a presented view controller (modal)
    let enterPincodeInContainerModule = EnterPinCodeInContainerModule(context: context,
                                                                      flow: authFlow,
                                                                      viewModel: viewModel)
    view.showChild(module: enterPincodeInContainerModule)
    //...
}
```

- `ChangePincodeModule`: _Provides the ability to display a pincode changing flow with an encapsulated retry module inside. If the old pincode is entered incorrectly three times, prompts to force reauthorization_

```swift
func changePincode() {
    let pinCodeLength = 4
    let storage: PinCodeStorageProtocol = PinCodeStorage(storage: StoreHelper.instance)
    let onOldPincodeWrongValue: (BaseView?) -> Void = { view in
        let storeHelper = StoreHelper.instance
        let incorrectCount: Int = (storeHelper.getValue(forKey: .incorrectPincodeChangeCount) ?? 0) + 1
        if incorrectCount < 3 {
            storeHelper.save(incorrectCount, type: Int.self, forKey: .incorrectPincodeChangeCount)
        } else {
            storeHelper.clearAllData()
            let alertAction = AlertAction(title: title,
                                          type: type,
                                          callback: { authService.logout() })
            let alertModule = CustomAlertModule(title: title,
                                                message: message
                                                actions: [alertAction])
            view?.showChild(module: module)
        }
    }

    let onPincodeChangedWithSuccess: ([Int], UINavigationController?) -> Void = { pincode, navController in
        authService.setPincode(pincode: pincode)
        guard let navigationController = (currentView as? UIViewController)?.navigationController,
              let view = currentView else { return }
              
        TemplateHandler.handle(Constants.successAlert, in: view) { [weak navigationController] _ in
            navigationController?.replaceTopViewControllers(count: 2, with: [], animated: true)
        }
    }
    
    let context = ChangePincodeModuleContext(storage: storage,
                                             pinCodeManager: authService,
                                             onOldPincodeWrongValue: onOldPincodeWrongValue,
                                             onPincodeChangedWithSuccess: onPincodeChangedWithSuccess)
    
    let changePincodeModule = ChangePincodeModule(pinCodeLength: pinCodeLength,
                                                  context: context)
    view.open(module: changePincodeModule)
}
```

---

## Code Verification

### Testing

In order to run tests and check coverage please follow next steps
We use [xcov](https://github.com/fastlane-community/xcov) in order to run
This guidline provides step-by-step instructions on running xcove locally through a shell script. Discover the process and locate the results conveniently in .html format.

1. Install [xcov](https://github.com/fastlane-community/xcov)
2. go to folder ./Scripts then run `sh xcove_runner.sh`
3. In order to check coverage report find the file `index.html` in the folder `../../xcove_output`.

We use `Scripts/.xcovignore` xcov configuration file in order to exclude files that are not going to be covered by unit tests (views, models and so on) from coverage result.


### Swiftlint

It is used [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions. The app should build and work without it, but if you plan to write code, you are encouraged to install SwiftLint.

You can run SwiftLint manully by running 
```bash
swiftlint Sources --quiet --reporter html > Scripts/swiftlint_report.html.
```
You can also set up a Git [pre-commit hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) to run SwiftLint automatically by copy Scripts/githooks into .git/hooks

## How to contribute

The Diia project welcomes contributions into this solution; please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) file for details

## Licensing

Copyright (C) Diia and all other contributors.

Licensed under the  **EUPL**  (the "License"); you may not use this file except in compliance with the License. Re-use is permitted, although not encouraged, under the EUPL, with the exception of source files that contain a different license.

You may obtain a copy of the License at  [https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

Questions regarding the Diia project, the License and any re-use should be directed to [modt.opensource@thedigital.gov.ua](mailto:modt.opensource@thedigital.gov.ua).
