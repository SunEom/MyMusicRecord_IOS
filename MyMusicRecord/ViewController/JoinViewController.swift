//
//  JoinViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/16.
//

import UIKit
import Alamofire

class JoinViewController: UIViewController {
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var idCheckbutton: UIButton!
    @IBOutlet weak var nicknameCheckButton: UIButton!
    
    var isIDAvailable: Bool = false
    var isNicknameAvailable: Bool = false
    var isKeyboardVisible: Bool = false
    var isViewMoved: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        setKeyboardObserver()
    }

    private func requestIDCheck() {
        if let length = idTextField.text?.count, length < 5 {
            Util.createSimpleAlert(self,title: "ID 오류", message: "ID는 5글자 이상 입력해야합니다.")
            return
        }
        
        guard let id = idTextField.text else { return }
        
        let PARAM:Parameters = [
            "id": id,
        ]
    
        AF.request("\(Env.getServerURL())/register/check_id", method: .post, parameters: PARAM)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                guard let value = value as? [String: Bool] else {return}
                guard let already = value["already_exist"] else { return }
                
                self.isIDAvailable = !already
                
                if already {
                    Util.createSimpleAlert(self,title: "ID 오류", message: "이미 사용중인 아이디입니다!")
                } else {
                    Util.createSimpleAlert(self,title: "ID 확인", message: "사용 가능한 아이디입니다!")
                }
                
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
    }

    private func requestNicknameCheck(){
        if let length = nicknameTextField.text?.count, length < 2 {
            Util.createSimpleAlert(self,title: "닉네임 오류", message: "닉네임은 2글자 이상 입력해야합니다.")
            return
        }
        
        guard let nickname = nicknameTextField.text else { return }
        
        let PARAM:Parameters = [
            "nickname": nickname,
        ]
    
        AF.request("\(Env.getServerURL())/register/check_nickname", method: .post, parameters: PARAM)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                guard let value = value as? [String: Bool] else {return}
                guard let already = value["already_exist"] else { return }
                
                self.isNicknameAvailable = !already
                
                if already {
                    Util.createSimpleAlert(self,title: "닉네임 오류", message: "이미 사용중인 닉네임입니다!")
                } else {
                    Util.createSimpleAlert(self,title: "닉네임 확인", message: "사용 가능한 닉네임입니다!")
                }
                
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
        
    }
    
    private func requestJoin() async {
        guard let id = idTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let nickname = nicknameTextField.text else { return }
        
        let PARAM:Parameters = [
            "id": id,
            "password": password,
            "nickname": nickname
        ]
    
        AF.request("\(Env.getServerURL())/register", method: .post, parameters: PARAM)
            .validate(statusCode: 200..<300)
            .responseString() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                Util.createSimpleAlert(self,title: "회원가입 성공", message: "정상적으로 회원가입 되었습니다!", navCon: self.navigationController)
                
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
    }
    
    private func checkPasswordIsAvailable() -> Bool {
        
        if passwordTextField.text != passwordCheckTextField.text {
            Util.createSimpleAlert(self,title: "비밀번호 오류", message: "비밀번호가 같지 않습니다.")
            return false
        }
        if let length = passwordTextField.text?.count, length < 6 {
            Util.createSimpleAlert(self,title: "비밀번호 오류", message: "비밀번호는 6자리 이상이어야합니다.")
            return false
        }
        return true
    }
    
    private func configureViewController() {
        idTextField.addTarget(self, action: #selector(self.idTextFieldDidChange(_:)), for: .editingChanged)
        nicknameTextField.addTarget(self, action: #selector(self.nicknameTextFieldDidChange(_:)), for: .editingChanged)
        
        idTextField.delegate = self
        passwordTextField.delegate = self
        passwordCheckTextField.delegate = self
        nicknameTextField.delegate = self
    }
    
    @objc private func idTextFieldDidChange(_ sender: Any?) {
        self.isIDAvailable = false
    }
    
    @objc private func nicknameTextFieldDidChange(_ sender: Any?) {
        self.isNicknameAvailable = false
    }
    
    @IBAction func tapIDCheckButton(_ sender: Any) {
        self.requestIDCheck()
    }
    
    @IBAction func tapNicknameCheckButton(_ sender: Any) {
        self.requestNicknameCheck()
    }
    
    @IBAction func tapJoinbutton(_ sender: Any) {
        if self.checkPasswordIsAvailable() == false { return }
        if self.isIDAvailable == false {
            Util.createSimpleAlert(self,title: "ID 오류", message: "ID 중복확인을 해주세요")
            return
        }
        
        if self.isNicknameAvailable == false {
            Util.createSimpleAlert(self,title: "닉네임 오류", message: "닉네임 중복확인을 해주세요")
            return
        }
        
        Task {
            await requestJoin()
        }
    }
    
    @IBAction func tapBackground(_ sender: Any) {
        self.view.endEditing(true)
    }
}

extension JoinViewController {
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object:nil)
    }
        
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.isKeyboardVisible {
            return
        }
        
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if idTextField.isEditing { return }
            UIView.animate(withDuration: 0.5) {
                self.view.window?.frame.origin.y -= 200
            }
            self.isViewMoved = true
            self.isKeyboardVisible = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if !self.isKeyboardVisible {
            return
        }
        
        if self.view.window?.frame.origin.y != 0 {
            if !self.isViewMoved { return }
            if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                UIView.animate(withDuration: 0.5) {
                    self.view.window?.frame.origin.y += 200
                }
                self.isViewMoved = false
                self.isKeyboardVisible = false
            }
        }
    }
}

extension JoinViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if textField == idTextField {
            return newLength <= 12
        } else if textField == passwordTextField || textField == passwordCheckTextField {
            return newLength <= 15
        } else {
            return newLength <= 10
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idTextField {
            idCheckbutton.sendActions(for: .touchUpInside)
            self.view.endEditing(true)
        } else if textField == passwordTextField {
            self.view.endEditing(true)
            passwordCheckTextField.becomeFirstResponder()
        } else if textField == passwordCheckTextField {
            self.view.endEditing(true)
            nicknameTextField.becomeFirstResponder()
        } else if textField == nicknameTextField {
            nicknameCheckButton.sendActions(for: .touchUpInside)
            self.view.endEditing(true)
        }
        return true
    }
}
