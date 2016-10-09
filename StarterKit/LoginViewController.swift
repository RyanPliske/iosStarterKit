import UIKit

internal protocol LoginViewControllerDelegate: class {
    func loginSucceeded(username: String, password: String)
    func loginFailed()
}

internal final class LoginViewController: UIViewController, UITextFieldDelegate {
    
    internal weak var delegate: LoginViewControllerDelegate!
    internal var image: UIImage?
    
    @IBOutlet internal weak var usernameTextField: UITextField!
    @IBOutlet internal weak var passwordTextField: UITextField!
    @IBOutlet internal weak var loginImageView: UIImageView!
    @IBOutlet internal weak var loginButton: LoginButton!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        loginImageView.image = image
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.enabled = false
    }
    
    // MARK: - UITextFieldDelegate
    
    internal func textFieldShouldReturn(textField: UITextField) -> Bool {
        if loginEnabled &&  textField == passwordTextField {
            textField.resignFirstResponder()
            delegate.loginSucceeded(usernameTextField.text!, password: passwordTextField.text!)
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    internal var loginEnabled: Bool {
        return usernameTextField.text != nil && passwordTextField.text != nil
    }
    
}