//
//  PostDetailViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/14.
//

import UIKit

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
    
    var post: Posting?
    var comments = [Comment]()
    
    var isKeyboardVisible: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationBar()
        configureCommentCollectionView()
        addCommentSamples()
        setKeyboardObserver()
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
    
    private func addCommentSamples() {
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello1", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello2", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello3", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello4", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello5", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello6", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello7", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello8", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        comments.append(Comment(postNum: 1, commentNum: 1, contents: "Hello9", writtenDate: Date(), updatedDate: Date(), commentID: 1, nickname: "Suneom"))
        
        commentTitleLabel.text = "Comments (\(self.comments.count))"
        
        commentCollectioinView.reloadData()
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
