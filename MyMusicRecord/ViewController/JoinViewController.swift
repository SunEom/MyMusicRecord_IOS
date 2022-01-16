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
        print("ID 중복확인을 요청합니다.")
        self.isIDAvailable = true
    }

    private func requestNicknameCheck(){
        print("닉네임 중복확인을 요청합니다.")
        self.isNicknameAvailable = true
    }
    
    private func requestJoin(){
        print("회원가입을 요청합니다.")
    }
    
    private func checkPasswordIsAvailable() -> Bool {
        if passwordTextField.text != passwordCheckTextField.text {
            print("비밀번호가 같지 않습니다.")
            return false
        }
        return true
    }
    
    private func configureViewController() {
        idTextField.addTarget(self, action: #selector(self.idTextFieldDidChange(_:)), for: .editingChanged)
        nicknameTextField.addTarget(self, action: #selector(self.nicknameTextFieldDidChange(_:)), for: .editingChanged)
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
            print("ID 중복확인을 해주세요")
            return
        }
        
        if self.isNicknameAvailable == false {
            print("닉네임 중복확인을 해주세요")
            return
        }
        
        self.requestJoin()
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
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if idTextField.isEditing { return }
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            guard let navigationBarHeight = self.navigationController?.navigationBar.frame.height else { return }
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
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                guard let navigationBarHeight = self.navigationController?.navigationBar.frame.height else { return }
                UIView.animate(withDuration: 0.5) {
                    self.view.window?.frame.origin.y += 200
                }
                self.isViewMoved = false
                self.isKeyboardVisible = false
            }
        }
    }
}
