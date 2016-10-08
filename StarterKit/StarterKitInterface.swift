import Foundation

public protocol Persistence: class {
    var filePath: String! { get set }
    var name: String { get }
}

// subclass this

public class PlistPersistence: Persistence {
    public var fileDict: [String: AnyObject]!
    public var filePath: String!
    public let name: String
    
    init(name: String) {
        self.name = name
    }
}

// subclass this

public class FilePersistence: Persistence {
    public var filePath: String!
    public let name: String
    
    init(name: String) {
        self.name = name
    }
}

// pass in your persistence classes that you subclassed from above and this will build the fire structure for you

public struct PersistenceInitializer {
    
    public init?(baseDirectory: String, persistenceStarters: [Persistence]) {
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
