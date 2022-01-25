//
//  NewPostingViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/20.
//

import UIKit
import Alamofire

class NewPostingViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var postBodyTextView: UITextView!
    @IBOutlet weak var popGenreButton: UIButton!
    @IBOutlet weak var kpopGenreButton: UIButton!
    @IBOutlet weak var rockGenreButton: UIButton!
    @IBOutlet weak var jazzGenreButton: UIButton!
    @IBOutlet weak var hiphopGenreButton: UIButton!
    @IBOutlet weak var discoGenreButton: UIButton!
    @IBOutlet weak var electronicGenreButton: UIButton!
    
    var selectedButton: UIButton?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(responseUserInfo(_:)), name: NSNotification.Name("responseUserInfo"), object: nil)
        
        NotificationCenter.default.post(name: Notification.Name("requestUserInfo"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInNotification(_:)), name: NSNotification.Name("signIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInNotification(_:)), name: NSNotification.Name("logOut"), object: nil)
    }
    
    @objc func responseUserInfo(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func signInNotification(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func logOutNotification(_ notification: Notification){
        self.user = nil
    }
    
    private func configureViewController() {
        self.postBodyTextView.layer.borderColor = UIColor.gray.cgColor
        self.postBodyTextView.layer.borderWidth = 0.2
        self.postBodyTextView.layer.cornerRadius = 10
    }
    
    private func resetInputs() {
        titleTextField.text = ""
        artistTextField.text = ""
        postBodyTextView.text = ""
        ratingTextField.text = ""
        if selectedButton != nil {
            selectedButton?.setTitleColor(.black, for: .normal)
            selectedButton?.backgroundColor = .lightGray
            selectedButton = nil
        }
    }
    
    @IBAction func tapGenreButton(_ sender: UIButton) {
        guard var genre = sender.title(for: .normal) else { return }
        genre = genre.uppercased()
        if selectedButton == nil {
            selectedButton = sender
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = .systemBlue
        } else {
            
            if selectedButton == sender {
                selectedButton = nil
                sender.setTitleColor(.black, for: .normal)
                sender.backgroundColor = .lightGray
            } else {
                selectedButton?.setTitleColor(.black, for: .normal)
                selectedButton?.backgroundColor = .lightGray
                sender.setTitleColor(.white, for: .normal)
                sender.backgroundColor = .systemBlue
                selectedButton = sender
            }
            
        }
        
    }
    
    @IBAction func tapBackground(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        if user == nil {
            Util.createSimpleAlert(self, title: "로그인", message: "로그인이 필요한 서비스입니다.")
            return
        }
        
        guard let title = titleTextField.text else { return }
        guard let artist = artistTextField.text else { return }
        guard let rating = ratingTextField.text else { return }
        guard let postBody = postBodyTextView.text else { return }
        guard let genre = selectedButton?.title(for: .normal) else {
            Util.createSimpleAlert(self, title: "입력 오류", message: "장르를 선택해주세요.")
            return
        }
        
        if title == "" {
            Util.createSimpleAlert(self, title: "입력 오류", message: "제목을 입력해주세요.")
            return
        }
        
        if artist == "" {
            Util.createSimpleAlert(self, title: "입력 오류", message: "가수를 입력해주세요.")
            return
        }
        
        if rating == "" {
            Util.createSimpleAlert(self, title: "입력 오류", message: "평점을 입력해주세요.")
            return
        }
        
        if Double(rating) == nil {
            Util.createSimpleAlert(self, title: "입력 오류", message: "평점은 0이상 5이하의 숫자입니다.")
            return
        } else {
            guard let rate = Double(rating) else { return }
            if rate > 5 {
                Util.createSimpleAlert(self, title: "입력 오류", message: "평점은 5점 이하입니다.")
                return
            } else if rate < 0 {
                Util.createSimpleAlert(self, title: "입력 오류", message: "평점은 0점 이상입니다.")
                return
            }
        }
        
        if postBody == "" {
            Util.createSimpleAlert(self, title: "입력 오류", message: "게시글 내용을 입력해주세요.")
            return
        }
        
        guard let rate = Double(rating) else { return }
        
        let PARAM: Parameters = [
            "title": title,
            "artist": artist,
            "post_body": postBody,
            "genre": genre.uppercased(),
            "rating": rate
        ]
        
        self.view.endEditing(true)
        
        AF.request("\(Env.getServerURL())/post/create", method: .post, parameters: PARAM)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    guard let data = value as? [String: Any] else { return }
                    guard let payload = data["payload"] as? [String: Any] else { return }
                    
                    guard let title = payload["title"] as? String else { return }
                    guard let artist = payload["artist"] as? String else { return }
                    guard let nickname = "Suneom" as? String else { return }
                    guard let genre = payload["genre"] as? String else { return }
                    guard let postBody = payload["post_body"] as? String else { return }
                    guard let postNum = payload["post_num"] as? Int else { return }
                    guard let rating = payload["rating"] as? Double else { return }
                    guard let writerId = payload["writer_id"] as? Int else { return }
                    guard let created = payload["created_date"] as? String else { return }
                    guard let createdDate = Util.StringToDate(date: String(created.split(separator: "T")[0])) else { return }
                    
                    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController else { return }
                    viewController.post = Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, postNum: postNum, rating: rating, writerId: writerId, createdDate: createdDate)
                    
                    viewController.user = self.user
                    
                    self.resetInputs()
                    
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                case .failure(let error):
                    print("Error: \(error)")
                    return
                }
            }
    }
}
