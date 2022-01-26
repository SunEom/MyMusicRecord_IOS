//
//  ProfileEditViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/17.
//

import UIKit
import Alamofire

class ProfileEditViewController: UIViewController {
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var popButton: UIButton!
    @IBOutlet weak var kpopButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var jazzButton: UIButton!
    @IBOutlet weak var hiphopButton: UIButton!
    @IBOutlet weak var discoButton: UIButton!
    @IBOutlet weak var electronicButton: UIButton!
    
    var user: User?
    var selectedGenre = [String]()
    var isChanged: Bool = false
    var isNicknameAvailable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backToProfile(sender:)))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(requestPatchProfile(sender:)))
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func requestPatchProfile(sender: AnyObject) {
        if isNicknameAvailable == false {
            Util.createSimpleAlert(self, title: "닉네임 오류", message: "닉네임 중복 확인 버튼을 눌러주세요.")
            return
        }
        
        guard let nickname = nicknameTextField.text else { return }
        guard let aboutMe = aboutMeTextView.text else { return }
        guard let genres = user?.genres as? [String] else { return }
        
        if nickname != user?.nickname {
            let PARAMS: Parameters = [
                "nickname" : nickname
            ]
            
            Task {
                await AF.request("\(Env.getServerURL())/mypage/nickname", method: .patch, parameters: PARAMS)
                    .validate(statusCode: 200..<300)
                    .responseJSON() { response in
                    switch response.result
                    {
                    //통신성공
                    case .success(let value):
                        guard var userData = self.user else { return }
                        userData.nickname = nickname

                    //통신실패
                    case .failure(let error):
                        print("error: \(String(describing: error.errorDescription))")
                }}
            }
            
        }
        
        if !(aboutMe == "" && user?.aboutMe == nil) && aboutMe != user?.aboutMe {
            let PARAMS: Parameters = [
                "aboutme" : aboutMe
            ]
            
            Task {
                await AF.request("\(Env.getServerURL())/mypage/aboutme", method: .patch, parameters: PARAMS)
                    .validate(statusCode: 200..<300)
                    .responseJSON() { response in
                    switch response.result
                    {
                    //통신성공
                    case .success(let value):
                        guard var userData = self.user else { return }
                        userData.aboutMe = aboutMe

                    //통신실패
                    case .failure(let error):
                        print("error: \(String(describing: error.errorDescription))")
                }}
            }
            
        }
        
        if genres != selectedGenre {
            let PARAMS: Parameters = [
                "genre" : selectedGenre
            ]
            Task {
                await AF.request("\(Env.getServerURL())/mypage/genre", method: .patch, parameters: PARAMS, encoding: URLEncoding(arrayEncoding: .noBrackets))
                    .validate(statusCode: 200..<300)
                    .responseJSON() { response in
                    switch response.result
                    {
                    //통신성공
                    case .success(let value):
                        guard let data = value as? [String: Any] else { return }
                        guard let payload = data["payload"] as? [String: Any] else { return }
                        guard let genres = payload["genres"] as? NSArray else { return }
                        guard var userData = self.user else { return }
                        userData.genres = genres
                      
                    //통신실패
                    case .failure(let error):
                        print("error: \(String(describing: error.errorDescription))")
                }}
            }
            
        }
        guard var userData = self.user else { return }
        userData.aboutMe = aboutMe
        userData.nickname = nickname
        userData.genres = NSArray(array: selectedGenre)
        NotificationCenter.default.post(name: Notification.Name("changeProfile"), object: userData)
        
        Util.createSimpleAlert(self, title: "수정 완료", message: "정상적으로 변경되었습니다.",navCon: self.navigationController)
        
    }
    
    @objc func backToProfile(sender: AnyObject){
        if isChanged {
            let alertController = UIAlertController(title: "주의", message: "저장하지 않고 나가시겠습니까?", preferredStyle: .alert)

            let cancelOption = UIAlertAction(title: "Leave", style: .destructive, handler: { action in
                self.navigationController?.popViewController(animated: true)
            })
            let saveOption = UIAlertAction(title: "Cancel", style: .default)
            
            alertController.addAction(saveOption)
            alertController.addAction(cancelOption)
            present(alertController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func profileDidChange(sender: AnyObject){
        isChanged = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func configureViewController() {
        guard let user = self.user as? User else { return }
        nicknameTextField.text = user.nickname
        aboutMeTextView.text = user.aboutMe
        
        aboutMeTextView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).cgColor
        aboutMeTextView.layer.borderWidth = 1.0
        
        nicknameTextField.addTarget(self, action: #selector(profileDidChange(sender:)), for: .editingChanged)
        aboutMeTextView.delegate = self
        
        guard let genres = user.genres as? [String] else { return }
        for genre in genres  {
            guard let genre = genre.uppercased() as? String else { return }
            selectedGenre.append(genre)
            
            var btn: UIButton
            switch genre {
            case "POP":
                btn = popButton
                
            case "K-POP":
                btn = kpopButton
                
            case "ROCK":
                btn = rockButton
                
            case "JAZZ":
                btn = jazzButton
                
            case "HIP-HOP":
                btn = hiphopButton
                
            case "DISCO":
                btn = discoButton
                
            case "ELECTRONIC":
                btn = electronicButton
                
            default:
                return
            }
            
            btn.backgroundColor = .systemBlue
            btn.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func tapGenreButtons(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
    
        if self.selectedGenre.contains(title.uppercased()) {
            sender.setTitleColor(.black, for: .normal)
            sender.backgroundColor = .lightGray
            guard let index = selectedGenre.firstIndex(of: title.uppercased()) else { return }
            selectedGenre.remove(at: index)
        } else {
            sender.setTitleColor(UIColor.white, for: .normal)
            sender.backgroundColor = .systemBlue
            selectedGenre.append(title.uppercased())
        }
        self.isChanged = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @IBAction func tapNicknameCheckButton(_ sender: Any) {
        guard let nickname = nicknameTextField.text else { return }

        if nickname == user?.nickname {
            Util.createSimpleAlert(self,title: "닉네임 오류", message: "현재 사용중인 닉네임입니다!")
            return
        }
        
        let PARAM: Parameters = [
            "nickname": nickname
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
    @IBAction func tapBackground(_ sender: Any) {
        self.view.endEditing(true)
    }
    
}

extension ProfileEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 12
    }
}

extension ProfileEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.aboutMeTextView{
            self.isChanged = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}
