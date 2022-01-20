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
    @IBOutlet weak var postBodyTextView: UITextView!
    @IBOutlet weak var popGenreButton: UIButton!
    @IBOutlet weak var kpopGenreButton: UIButton!
    @IBOutlet weak var rockGenreButton: UIButton!
    @IBOutlet weak var jazzGenreButton: UIButton!
    @IBOutlet weak var hiphopGenreButton: UIButton!
    @IBOutlet weak var discoGenreButton: UIButton!
    @IBOutlet weak var electronicGenreButton: UIButton!
    
    var selectedButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
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
    
    @IBAction func tapAddButton(_ sender: Any) {
        guard let title = titleTextField.text else { return }
        guard let artist = artistTextField.text else { return }
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
        
        if postBody == "" {
            Util.createSimpleAlert(self, title: "입력 오류", message: "게시글 내용을 입력해주세요.")
            return
        }
        
        let PARAM: Parameters = [
            "title": title,
            "artist": artist,
            "post_body": postBody,
            "genre": genre.uppercased()
        ]
        
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
                    guard let created = payload["created_date"] as? String else { return }
                    guard let createdDate = Util.StringToDate(date: String(created.split(separator: "T")[0])) else { return }
                    
                    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController else { return }
                    viewController.post = Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, createdDate: createdDate)
                    
                    self.resetInputs()
                    
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                case .failure(let error):
                    print("Error: \(error)")
                    return
                }
            }
    }
}
