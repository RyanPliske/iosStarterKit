internal typealias LoginCompletion = (isLoginSuccessful: Bool) -> Void

internal protocol AuthenticationDelegate: class {
    func loginSucceeded(username: String, password: String)
}

internal final class FakeAuthenticationManager: LoginViewControllerDelegate {
    
    internal let serviceManager: FakeAuthenticationServiceManager
    internal let keyChainHelper: FakeKeyChainHelper
    internal weak var delegate: AuthenticationDelegate?
    
    internal init(serviceManager: FakeAuthenticationServiceManager, keyChainHelper: FakeKeyChainHelper) {
        self.serviceManager = serviceManager
        self.keyChainHelper = keyChainHelper
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
    
    internal func loginFailed() {
        // TODO: Display Login Failure
    }
    
    func loginSucceeded(username: String, password: String) {
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