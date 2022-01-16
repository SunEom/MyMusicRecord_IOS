//
//  LoginViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/15.
//

import UIKit
import SwiftUI

class LoginViewController: UIViewController {
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func idCheckButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureViewController()
        
    }
    
    
    
    private func cofigureViewController() {
        if let _ = self.navigationController?.navigationBar.items?[0].title {
            self.navigationController?.navigationBar.items?[0].title = "Home"
        }
        
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func sendLoginRequest(){
        
    }

    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func tapLoginButton(_ sender: Any) {
        sendLoginRequest()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapJoinButton(_ sender: Any) {
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 15
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            loginButton.sendActions(for: .touchUpInside)
            self.view.endEditing(true)
        } else if textField == idTextField {
            self.view.endEditing(true)
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
}
