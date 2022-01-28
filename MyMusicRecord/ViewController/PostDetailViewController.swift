//
//  PostDetailViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/14.
//

import UIKit
import Alamofire

class PostDetailViewController: UIViewController, NewPostingDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(commentUpdatedNotification(_:)), name: NSNotification.Name("CommentUpdated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let post = self.post else { return }
        AF.request("\(Env.getServerURL())/post/\(post.postNum)", method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    guard let data = value as? [String: Any] else { return }
                    guard let payload = data["payload"] as? [String: Any] else { return }
                    
                    guard let post = payload["post"] as? [String: Any] else { return }
                    guard let user = payload["user"] as? [String: Any] else { return }
                    
                    guard let title = post["title"] as? String else { return }
                    guard let artist = post["artist"] as? String else { return }
                    guard let nickname = post["nickname"] as? String else { return }
                    guard let genre = post["genre"] as? String else { return }
                    guard let postBody = post["post_body"] as? String else { return }
                    guard let postNum = post["post_num"] as? Int else { return }
                    guard let rating = post["rating"] as? Double else { return }
                    guard let writerId = post["writer_id"] as? Int else { return }
                    guard let created = post["created_date"] as? String else { return }
                    guard let createdDate = Util.StringToDate(date: String(created.split(separator: "T")[0])) else { return }
                    
                    self.post = Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, postNum: postNum, rating: rating, writerId: writerId, createdDate: createdDate)
                    
                    guard let posting = self.post else { return }
                    
                    self.titleLabel.text = posting.title
                    self.artistLabel.text = posting.artist
                    self.genreLabel.text = posting.genre
                    self.postBodyTextView.text = posting.postBody
                    self.userLabel.text = posting.nickname
                    self.dateLabel.text = String(created.split(separator: "T")[0])
                    self.ratingLabel.text = "⭐️ \(posting.rating) / 5.0"
                    
                case.failure(let error):
                    print("Error: \(error)")
                }
            }
        
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
        
        guard let userId = self.user?.id else { return }
        guard let writerId = self.post?.writerId else { return }
        
        if userId == writerId {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(tapEditButton))
        }
        
    }
    
    private func configureViewController() {
        guard let title = post?.title else { return }
        guard let artist = post?.artist else { return }
        guard let genre = post?.genre else { return }
        guard let postBody = post?.postBody else { return }
        guard let nickname = post?.nickname else { return }
        guard let created = post?.createdDate else { return }
        guard let rating = post?.rating else { return }
        let createdDate = Util.DateToString(date: created)
        
        titleLabel.text = title
        artistLabel.text = artist
        genreLabel.text = genre
        postBodyTextView.text = postBody
        userLabel.text = nickname
        dateLabel.text = createdDate
        ratingLabel.text = "⭐️ \(rating) / 5.0"
        
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
        
        AF.request("\(Env.getServerURL())/comment/\(postNum)", method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    guard let value = value as? [String: Any] else { return }
                    guard let payload = value["payload"] as? [[String: Any]] else { return }
                    
                    self.comments.removeAll()
                    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let NewPostingViewController = segue.destination as? NewPostingViewController {
                NewPostingViewController.delegate = self
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
    
    @objc func commentUpdatedNotification(_ notification: Notification){
        self.requestGetComments()
    }
    
    @objc func tapEditButton(){
        guard let viewContainer = self.storyboard?.instantiateViewController(withIdentifier: "NewPostingViewController") as? NewPostingViewController else { return }
        guard let posting = self.post else { return }
        viewContainer.post = post
        viewContainer.delegate = self
        self.navigationController?.pushViewController(viewContainer, animated: true)
    }
    
    func updatePosting(posting: Posting) {
        self.post = posting
        let createdDate = Util.DateToString(date: posting.createdDate)
        
        titleLabel.text = posting.title
        artistLabel.text = posting.artist
        genreLabel.text = posting.genre
        postBodyTextView.text = posting.postBody
        userLabel.text = posting.nickname
        dateLabel.text = createdDate
        ratingLabel.text = "⭐️ \(posting.rating) / 5.0"
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
        
        cell.comment = comment
        cell.navigationController = self.navigationController
        cell.nicknameLabel.text = comment.nickname
        cell.contentsTextField.text = comment.contents
        
        cell.divider.layer.borderWidth = 0.5
        cell.divider.layer.borderColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0).cgColor
        
        if user == nil {
            cell.buttonStackView.isHidden = true
        }
        
        if let user = self.user, user.id != comment.commenterID {
            cell.buttonStackView.isHidden = true
        }
        
        return cell
    }
}

extension PostDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
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
