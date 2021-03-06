//
//  LoginViewController.swift
//  On the Map
//
//  Created by Carmine Totera on 2021/8/11.
//  Copyright © 2021 Carmine Totera. All rights reserved.
//


import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Actions

    @IBAction func loginPressed(_ sender: Any) {
        userDidTapView(self)
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            UdacityClient.sharedInstance.displayAlert(self, title: "", message: ErrorMessage.EmptyEmailOrPassword)
        } else {
            setUIEnabled(false)
    
            
            UdacityClient.sharedInstance.getUserId(username: emailTextField.text!, password: passwordTextField.text!) { (success, error, errorMessage) in
                if success {
                    UdacityClient.sharedInstance.getUserData(userID: UdacityClient.sharedInstance.userID!) { (success, error) in
                        DispatchQueue.main.async {
                            if success {
                                self.completeLogin()
                            } else {
                                self.setUIEnabled(true)
                                UdacityClient.sharedInstance.displayAlert(self, title: "", message: ErrorMessage.NoNetwork)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.setUIEnabled(true)
                        UdacityClient.sharedInstance.displayAlert(self, title: "", message: errorMessage!)
                    }
                }
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(URL(string: UdacityClient.Constants.SignUpURL)!,
                                  options: [:], completionHandler: nil)
    }
    
    // MARK: Login
    
    private func completeLogin() {
        setUIEnabled(true)
        UdacityClient.sharedInstance.getUserPostedInfo(uniqueKey: UdacityClient.sharedInstance.userID!)
        let controller = storyboard!.instantiateViewController(withIdentifier: "MapTabBarNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardDidShow(_ notification: Notification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(emailTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
            loginIndicator.alpha = 0.0
             loginIndicator.stopAnimating()
        } else {
            loginButton.alpha = 0.5
            loginIndicator.alpha = 1.0
            loginIndicator.startAnimating()
        }
    }
}


// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
