import UIKit

internal protocol LoginViewControllerDelegate: class {
    func loginSucceeded(username: String, password: String)
    func loginFailed()
    func facebookLoginRequested(viewController: UIViewController)
}

internal final class LoginViewController: UIViewController, UITextFieldDelegate {
    
    internal weak var delegate: LoginViewControllerDelegate?
    internal var appInfo: AppInfo!
    
    @IBOutlet internal weak var usernameTextField: UITextField!
    @IBOutlet internal weak var passwordTextField: UITextField!
    @IBOutlet internal weak var loginImageView: UIImageView!
    @IBOutlet internal weak var loginButton: LoginButton!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 146/255, green: 204/255, blue: 148/255, alpha: 1.0)
        loginImageView.image = appInfo.loginBgImage
        usernameTextField.delegate = self
        passwordTextField.delegate = self
//        registerButton.hidden = !appInfo.includesRegistration
        disableLoginButton()
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        view.endEditing(true)
        delegate?.loginSucceeded(usernameTextField.text!, password: passwordTextField.text!)
    }
    
    private func disableLoginButton() {
        loginButton.enabled = false
        loginButton.alpha = 0.2
    }
    
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        delegate?.facebookLoginRequested(self)
    }
    
    @IBAction func usernameTextChanged(sender: AnyObject) {
        loginEnabled()
    }
    
    @IBAction func passwordTextChanged(sender: AnyObject) {
        loginEnabled()
    }
    // MARK: - UITextFieldDelegate
    
    internal func textFieldShouldReturn(textField: UITextField) -> Bool {
        if loginEnabled() &&  textField == passwordTextField {
            textField.resignFirstResponder()
            delegate?.loginSucceeded(usernameTextField.text!, password: passwordTextField.text!)
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    private func loginEnabled() -> Bool {
        let enabled = usernameTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        if enabled {
            loginButton.enabled = true
            loginButton.alpha = 1.0
        } else {
            disableLoginButton()
        }
        return enabled
    }
    
}