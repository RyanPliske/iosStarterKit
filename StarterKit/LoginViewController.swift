import UIKit

internal protocol LoginViewControllerDelegate: class {
    func loginSucceeded(username: String, password: String)
    func loginFailed()
}

internal final class LoginViewController: UIViewController, UITextFieldDelegate {
    
    internal weak var delegate: LoginViewControllerDelegate?
    internal var appInfo: AppInfo!
    
    @IBOutlet internal weak var usernameTextField: UITextField!
    @IBOutlet internal weak var passwordTextField: UITextField!
    @IBOutlet internal weak var loginImageView: UIImageView!
    @IBOutlet internal weak var loginButton: LoginButton!
    @IBOutlet weak var registerButton: UIButton!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 146/255, green: 204/255, blue: 148/255, alpha: 1.0)
        loginImageView.image = appInfo.loginBgImage
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.enabled = false
        registerButton.hidden = !appInfo.includesRegistration
    }
    
    // MARK: - UITextFieldDelegate
    
    internal func textFieldShouldReturn(textField: UITextField) -> Bool {
        if loginEnabled &&  textField == passwordTextField {
            textField.resignFirstResponder()
            delegate?.loginSucceeded(usernameTextField.text!, password: passwordTextField.text!)
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    internal var loginEnabled: Bool {
        return usernameTextField.text != nil && passwordTextField.text != nil
    }
    
}