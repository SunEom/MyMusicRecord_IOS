//
//  MyPageViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/17.
//

import UIKit
import Alamofire

class MyPageViewController: UIViewController {
    @IBOutlet weak var nicknameDivider: UITextView!
    @IBOutlet weak var aboutMeDivider: UITextView!
    @IBOutlet weak var preferGenreDivider: UITextView!
    @IBOutlet weak var nicknameTitleLabel: UILabel!
    @IBOutlet weak var aboutmeTitleLabel: UILabel!
    @IBOutlet weak var preferGenreTitleLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var preferGenreLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDiviers()
        configureViewController()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeProfileNotification(_:)),
            name: Notification.Name("changeProfile"),
            object: nil)
    }
    
    private func configureViewController() {
        guard let user = self.user else { return }
        
        self.setNickname()
        self.setAboutMe()
        self.setPreferGenres()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(tapEditButton))
    }
    
    private func setNickname() {
        self.nicknameLabel.text = self.user?.nickname
    }
    
    private func setAboutMe() {
        if let aboutMe = self.user?.aboutMe {
            self.aboutMeTextView.text = aboutMe
        } else {
            self.aboutMeTextView.text = "None"
        }
        
        // About Me Width 조정
        let fixedWidth = self.aboutMeTextView.frame.size.width
        let newSize = self.aboutMeTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.aboutMeTextView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
    
    private func setPreferGenres() {
        guard let user = self.user else { return }
        if user.genres.count == 0 {
            self.preferGenreLabel.text = "None"
            return
        }
        
        var tempString = ""
        
        for gen in user.genres {
            guard let gen = gen as? String else { return }
            tempString += "\(gen),  "
        }
        
        guard let subIndex = tempString.lastIndex(of: ",") else { return }
        self.preferGenreLabel.text = tempString.substring(to: subIndex)
    }
    
    private func configureDiviers(){
        nicknameDivider.layer.borderColor = UIColor.gray.cgColor
        aboutMeDivider.layer.borderColor = UIColor.gray.cgColor
        preferGenreDivider.layer.borderColor = UIColor.gray.cgColor
        
        nicknameDivider.layer.borderWidth = 1.0
        aboutMeDivider.layer.borderWidth = 1.0
        preferGenreDivider.layer.borderWidth = 1.0
    }
    
    @objc func tapEditButton() {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else { return }
        
        guard let user = user else { return }
        viewController.user = user
    
        self.navigationController?.pushViewController(viewController, animated: true)
                
    }
    
    @objc func changeProfileNotification(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user

        self.setNickname()
        self.setAboutMe()
        self.setPreferGenres()
    }
    
    @IBAction func tapLogOutButton(_ sender: Any) {
        AF.request("\(Env.getServerURL())/auth/login", method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                NotificationCenter.default.post(name: NSNotification.Name("logOut"), object: nil)
                UserDefaults.standard.set(nil, forKey: "signInInfo")
                Util.createSimpleAlert(self, title: "로그아웃", message: "정상적으로 로그아웃 되었습니다.", navCon: self.navigationController)
                
                
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
    }
}
