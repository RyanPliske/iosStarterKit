import FBSDKCoreKit
import FBSDKLoginKit

protocol AuthorizationClientDelegate {
    func intializeClient(logins: [String: String], clearCredentials: Bool)
}

protocol AuthorizationManagerSigninDelegate: class {
    func signingIn()
    func signInCanceled()
    func signInCompleted(error: String?)
}

final class FacebookAuthorizationManager {
    var authorizationClientDelegate: AuthorizationClientDelegate?
    weak var authorizationManagerSigninDelegate: AuthorizationManagerSigninDelegate?
    
    init(facebookAppId: String, facebookAppDisplayName: String) {
        FBSDKSettings.setAppID(facebookAppId)
        FBSDKSettings.setDisplayName(facebookAppDisplayName)
    }
    
    func presentFacebookLogin(viewController: UIViewController) {
        func facebookLogin() {
            let loginManager = FBSDKLoginManager()
            loginManager.loginBehavior = .SystemAccount
            loginManager.logInWithReadPermissions(["email"], fromViewController: viewController) { [unowned self] (result, error) -> Void in
                if (error != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.authorizationManagerSigninDelegate?.signInCompleted("Unable to authenticate. Please try again later")
                    }
                } else if result.isCancelled {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.authorizationManagerSigninDelegate?.signInCanceled()
                    }
                } else {
                    self.completeFacebookLogin()
                }
            }
        }
        
        authorizationManagerSigninDelegate?.signingIn()
        FBSDKAccessToken.currentAccessToken() != nil ? completeFacebookLogin() : facebookLogin()
    }
    
    func facebookLogout() {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .SystemAccount
        loginManager.logOut()
    }
    
    private func completeFacebookLogin() {
        //TODO, no longer needed but need to validate if sign in is completed?
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email"]).startWithCompletionHandler({ [unowned self] (connection, result, error) -> Void in
            
            guard error == nil, let email = result.objectForKey("email") as? String else {
                dispatch_async(dispatch_get_main_queue()) { self.authorizationManagerSigninDelegate?.signInCompleted("Unable to Authenticate with Facebook. Please try again later.") }
                return
            }
            
//            Crashlytics.sharedInstance().setUserEmail(email)
            
            self.authorizationClientDelegate?.intializeClient(["graph.facebook.com" : FBSDKAccessToken.currentAccessToken().tokenString], clearCredentials: true)
            })
    }
}

extension FacebookAuthorizationManager {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}