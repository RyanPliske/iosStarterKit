import UIKit

internal typealias LoginCompletion = (isLoginSuccessful: Bool) -> Void

internal protocol AuthenticationDelegate: class {
    func loginSucceeded(username: String, password: String)
}

internal final class FakeAuthenticationManager: LoginViewControllerDelegate {
    
    internal weak var delegate: AuthenticationDelegate?
    
    private let serviceManager: FakeAuthenticationServiceManager
    private let keyChainHelper: FakeKeyChainHelper
    private let facebookManager: FacebookAuthorizationManager?
    
    internal init(serviceManager: FakeAuthenticationServiceManager, keyChainHelper: FakeKeyChainHelper, facebookManager: FacebookAuthorizationManager? = nil) {
        self.serviceManager = serviceManager
        self.keyChainHelper = keyChainHelper
        self.facebookManager = facebookManager
    }
    
    internal func authenticate(username: String, password: String, completion: LoginCompletion) {
        serviceManager.authenticate(username, password: password) { [weak self](isLoginSuccessful) in
            if isLoginSuccessful {
                self?.keyChainHelper.store(username, password: password)
                completion(isLoginSuccessful: true)
            } else {
                completion(isLoginSuccessful: false)
            }
        }
    }
    
    func facebookLoginRequested(viewController: UIViewController) {
        self.facebookManager?.presentFacebookLogin(viewController)
    }
    
    internal func loginFailed() {
        // TODO: Display Login Failure
    }
    
    internal func loginSucceeded(username: String, password: String) {
        delegate?.loginSucceeded(username, password: password)
    }

}

internal final class FakeAuthenticationServiceManager {
    internal func authenticate(username: String, password: String, completion: LoginCompletion) {
        completion(isLoginSuccessful: true)
    }
}

internal final class FakeKeyChainHelper {
    func store(username: String, password: String) {
        
    }
}