//
//  PostDetailViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/14.
//

import UIKit
import Alamofire

class PostDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var postBodyTextView: UITextView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bottomDivider: UITextView!
    @IBOutlet weak var topDivider: UITextView!
    @IBOutlet weak var commentCollectioinView: UICollectionView!
    @IBOutlet weak var commentInputTextView: UITextView!
    @IBOutlet weak var commentDivider: UITextView!
    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentCreateButton: UIButton!
    
    var post: Posting?
    var comments = [Comment]()
    var user: User?
    
    var isKeyboardVisible: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationBar()
        configureCommentCollectionView()
        setKeyboardObserver()
        requestGetComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInNotification(_:)), name: NSNotification.Name("signIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOutNotification(_:)), name: NSNotification.Name("logOut"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if user == nil {
            self.commentInputTextView.isEditable = false
            self.commentInputTextView.isSelectable = false
            self.commentCreateButton.isEnabled = false
            self.commentCreateButton.setTitle("등록", for: .disabled)
            self.commentCreateButton.setTitleColor(.lightGray, for: .disabled)
            self.commentInputTextView.text = "로그인을 해주세요."
            self.commentInputTextView.textColor = .lightGray
        } else {
            self.commentInputTextView.isEditable = true
            self.commentCreateButton.isEnabled = true
            self.commentInputTextView.text = ""
            self.commentInputTextView.textColor = .black
        }
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func configureViewController() {
        guard let title = post?.title else { return }
        guard let artist = post?.artist else { return }
        guard let genre = post?.genre else { return }
        guard let postBody = post?.postBody else { return }
        guard let nickname = post?.nickname else { return }
        guard let created = post?.createdDate else { return }
        let createdDate = Util.DateToString(date: created)
        
        titleLabel.text = title
        artistLabel.text = artist
        genreLabel.text = genre
        postBodyTextView.text = postBody
        userLabel.text = nickname
        dateLabel.text = createdDate
        
        topDivider.layer.borderWidth = 1.0
        topDivider.layer.borderColor = UIColor.gray.cgColor
        bottomDivider.layer.borderWidth = 1.0
        bottomDivider.layer.borderColor = UIColor.gray.cgColor
        commentDivider.layer.borderWidth = 1.0
        commentDivider.layer.borderColor = UIColor.gray.cgColor
        
        commentInputTextView.layer.borderColor = UIColor.black.cgColor
        commentInputTextView.layer.borderWidth = 0.5
    }
    
    private func configureCommentCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        commentCollectioinView.collectionViewLayout = layout
        commentCollectioinView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        commentCollectioinView.delegate = self
        commentCollectioinView.dataSource = self
    }
    
    private func setCommentsCount(){
        self.commentTitleLabel.text = "Comments (\(comments.count))"
    }
    
    private func resetCommentTextView() {
        self.commentInputTextView.text = ""
    }

    private func requestGetComments(){
        guard let postNum = self.post?.postNum else { return }
        
        comments.removeAll()
        
        AF.request("\(Env.getServerURL())/comment/\(postNum)", method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    guard let value = value as? [String: Any] else { return }
                    guard let payload = value["payload"] as? [[String: Any]] else { return }
                    
                    for comment in payload {
                        guard let postNum = comment["post_num"] as? Int else { return }
                        guard let commentNum = comment["comment_num"] as? Int else { return }
                        guard let contents = comment["comment"] as? String else { return }
                        guard let written = comment["written_date"] as? String else { return }
                        guard let commenterID = comment["commenter"] as? Int else { return }
                        guard let nickname = comment["nickname"] as? String else { return }
                        guard let writtenDate = Util.StringToDate(date: String(written.split(separator: "T")[0])) else { return }
                        
                        self.comments.append(Comment(postNum: postNum, commentNum: commentNum, contents: contents, writtenDate: writtenDate, updatedDate: nil, commenterID: commenterID, nickname: nickname))
                    }
                    
                    self.commentCollectioinView.reloadData()
                    self.setCommentsCount()
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
    private func requestAddNewComment() {
        guard let comment = self.commentInputTextView.text else { return }
        
        if comment == "" {
            Util.createSimpleAlert(self, title: "댓글 오류", message: "댓글의 내용을 입력해주세요.")
            return
        }
        
        let PARAM: Parameters = [
            "post_num": self.post?.postNum,
            "comment": comment
        ]
        
        AF.request("\(Env.getServerURL())/comment/create", method: .post, parameters: PARAM)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    self.comments.removeAll()
                    guard let value = value as? [String: Any] else { return }
                    guard let payload = value["payload"] as? [[String: Any]] else { return }
                    
                    for comment in payload {
                        guard let postNum = comment["post_num"] as? Int else { return }
                        guard let commentNum = comment["comment_num"] as? Int else { return }
                        guard let contents = comment["comment"] as? String else { return }
                        guard let written = comment["written_date"] as? String else { return }
                        guard let commenterID = comment["commenter"] as? Int else { return }
                        guard let nickname = comment["nickname"] as? String else { return }
                        guard let writtenDate = Util.StringToDate(date: String(written.split(separator: "T")[0])) else { return }
                        
                        self.comments.append(Comment(postNum: postNum, commentNum: commentNum, contents: contents, writtenDate: writtenDate, updatedDate: nil, commenterID: commenterID, nickname: nickname))
                    }
                    
                    self.resetCommentTextView()
                    self.commentCollectioinView.reloadData()
                    self.setCommentsCount()
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
    @objc func logOutNotification(_ notification: Notification){
        self.user = nil
        self.commentInputTextView.isEditable = false
        self.commentInputTextView.text = "로그인을 해주세요."
    }
    
    @objc func signInNotification(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
        self.commentInputTextView.isEditable = true
        self.commentInputTextView.text = ""
    }
    
    @IBAction func tapAddNewCommentButton(_ sender: Any) {
        self.requestAddNewComment()
    }
    
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
}

extension PostDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCell", for: indexPath) as? CommentCell else { return UICollectionViewCell()}
        
        let comment = comments[indexPath.row]
        
        cell.nicknameLabel.text = comment.nickname
        cell.contentsTextView.text = comment.contents
        cell.contentsTextView.textContainerInset = UIEdgeInsets(top: 3, left: -5, bottom: 0, right: 0)
        
        cell.divider.layer.borderWidth = 0.5
        cell.divider.layer.borderColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0).cgColor
        
        if let user = self.user, user.id != comment.commenterID {
            cell.buttonStackView.isHidden = true
        }
        
        return cell
    }
}

extension PostDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 130)
    }
}

extension PostDetailViewController {
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object:nil)
    }
        
    @objc func keyboardWillShow(notification: NSNotification) {
        if isKeyboardVisible {
            return
        }
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y -= keyboardHeight
            }
            isKeyboardVisible = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if !isKeyboardVisible {
            return
        }
        
        if self.view.window?.frame.origin.y != 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y += keyboardHeight
                }
                isKeyboardVisible = false
            }
        }
    }
}
