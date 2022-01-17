//
//  LoginViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/15.
//

import UIKit
import SwiftUI
import Alamofire

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
        guard let id = idTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if id.count == 0 {
            Util.createSimpleAlert(self, title: "로그인 오류", message: "아이디를 입력해주세요.", completion: nil)
            return
        }
        
        if password.count == 0 {
            Util.createSimpleAlert(self, title: "로그인 오류", message: "비밀번호를 입력해주세요.", completion: nil)
            return
        }
                
        let PARAM:Parameters = [
            "id": id,
            "password": password,
        ]
    
        AF.request("\(Env.getServerURL())/auth/login", method: .post, parameters: PARAM)
            .validate(statusCode: 200..<300)
            .responseString() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                print(value)
                self.navigationController?.popViewController(animated: true)
                
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
        
        
    }

    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func tapLoginButton(_ sender: Any) {
        sendLoginRequest()
        
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
