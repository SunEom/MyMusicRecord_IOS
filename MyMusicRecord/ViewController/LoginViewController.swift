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
            .responseJSON() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                guard let data = value as? [String: Any] else { return }
                guard let userData = data["payload"] as? [String: Any] else { return }
                guard let id = userData["id"] as? Int else { return }
                guard let userId = userData["user_id"] as? String else { return }
                guard let genres = userData["genres"] as? NSArray else { return }
                guard let nickname = userData["nickname"] as? String else { return }
//                guard let aboutMe = userData["about_me"] as? String? else { return }
                let aboutMe = ""
                guard let password = userData["password"] as? String else { return }
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("signIn"),
                    object: User(id: id, userId: userId, genres: genres, nickname: nickname, aboutMe: aboutMe, password: password),
                    userInfo: nil)
                
                UserDefaults.standard.set(PARAM, forKey: "signInInfo")
                Util.createSimpleAlert(self, title: "로그인 성공", message: "\(nickname)님 반갑습니다!", navCon: self.navigationController)
                
                
                
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
