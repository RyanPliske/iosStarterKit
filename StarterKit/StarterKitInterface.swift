import Foundation
import UIKit

public struct AppInfo {
    internal let appName: String?
    internal let loginBgImage: UIImage?
    internal let includesRegistration: Bool
    internal let facebookInfo: FacebookInfo?
    
    public init(appName: String? = nil, loginBackground bgImage: UIImage? = nil, includesRegistration: Bool = false, facebookInfo: FacebookInfo? = nil) {
        self.appName = appName
        self.loginBgImage = bgImage
        self.includesRegistration = includesRegistration
        self.facebookInfo = facebookInfo
    }
}

public struct FacebookInfo {
    internal let facebookAppId: String
    internal let facebookAppDisplayName: String
    
    public init(facebookAppId: String, facebookAppDisplayName: String) {
        self.facebookAppId = facebookAppId
        self.facebookAppDisplayName = facebookAppDisplayName
    }
}

public struct Credentials {
    public let username: String
    public let password: String
    
    public init(username:String, password: String) {
        self.username = username
        self.password = password
    }
}

public protocol StarterKitDelegate: class {
    func userWasAuthenticated(withCredentials credentials: Credentials)
}

public class Starter: AuthenticationDelegate {
    
    private let window: UIWindow
    private let hostAppInitialViewController: UIViewController
    private let authenticationManager: FakeAuthenticationManager
    private weak var delegate: StarterKitDelegate!
    
    public init(inout window: UIWindow?, initialViewController: UIViewController, delegate: StarterKitDelegate, appInfo: AppInfo) {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window = window!
        self.hostAppInitialViewController = initialViewController
        var facebookManager: FacebookAuthorizationManager? = nil
        if let fbInfo = appInfo.facebookInfo {
            facebookManager = FacebookAuthorizationManager(facebookAppId: fbInfo.facebookAppId, facebookAppDisplayName: fbInfo.facebookAppDisplayName)
        }
        self.authenticationManager = FakeAuthenticationManager(serviceManager: FakeAuthenticationServiceManager(), keyChainHelper: FakeKeyChainHelper(), facebookManager: facebookManager)
        self.delegate = delegate
        // Post Initialization
        self.authenticationManager.delegate = self
        self.window.makeKeyAndVisible()
        let storyboard = UIStoryboard(name: "Login", bundle: NSBundle.StarterKitBundle)
        let loginVC = storyboard.instantiateInitialViewController() as! LoginViewController
        loginVC.delegate = authenticationManager
        loginVC.appInfo = appInfo
        self.window.rootViewController = loginVC
    }
    
    internal func loginSucceeded(username: String, password: String) {
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            self?.window.rootViewController!.view.alpha = 0.0
        }) { [weak self](cancelled) in
            self?.window.rootViewController = self?.hostAppInitialViewController
            self?.delegate.userWasAuthenticated(withCredentials: Credentials(username: username, password: password))
        }
    }
    
}

// MARK: - Persistence

public protocol Persistence: class {
    var filePath: String! { get set }
    var name: String { get }
}

// subclass this

public class PlistPersistence: Persistence {
    public var fileDict: [String: AnyObject]!
    public var filePath: String!
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

// subclass this

public class FilePersistence: Persistence {
    public var filePath: String!
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

// pass in your persistence classes that you subclassed from above and this will build the file structure for you

public struct PersistenceInitializer {
    
    public init?(baseDirectory: String, userDirectory: String, persistenceStarters: [Persistence]) {
        let fileManager = NSFileManager.defaultManager()
        guard var baseURL = try? fileManager.URLForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true) else {
            return nil
        }
        
        baseURL = baseURL.URLByAppendingPathComponent(baseDirectory)
        
        if fileManager.fileExistsAtPath(baseURL.path!) == false {
            guard let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(baseURL, withIntermediateDirectories: true, attributes: nil) else {
                return nil
            }
        }
        
        baseURL = baseURL.URLByAppendingPathComponent(userDirectory)
        
        if fileManager.fileExistsAtPath(baseURL.path!) == false {
            guard let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(baseURL, withIntermediateDirectories: true, attributes: nil) else {
                return nil
            }
        }
        
        for persistence in persistenceStarters {
            if let pListPersistence = persistence as? PlistPersistence {
                guard let pathToPlist = baseURL.URLByAppendingPathComponent(persistence.name + ".plist").path else {
                    return nil
                }
                let fileManager = NSFileManager.defaultManager()
                if !fileManager.fileExistsAtPath(pathToPlist) {
                    let result = fileManager.createFileAtPath(pathToPlist, contents: nil, attributes: nil)
                    if result == false {
                        return nil
                    }
                }
                var fileDict: [String: AnyObject]
                if let file = NSDictionary(contentsOfFile: pathToPlist) {
                    fileDict = (file as! [String: AnyObject])
                } else {
                    fileDict = NSDictionary() as! [String : AnyObject]
                }
                pListPersistence.filePath = pathToPlist
                pListPersistence.fileDict = fileDict
            } else if let filePersistence = persistence as? FilePersistence {
                guard let directoryPath = baseURL.URLByAppendingPathComponent(persistence.name).path else {
                    return nil
                }
                guard let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: directoryPath), withIntermediateDirectories: true, attributes: nil) else {
                    return nil
                }
                filePersistence.filePath = directoryPath
            }
        }
    }
}
