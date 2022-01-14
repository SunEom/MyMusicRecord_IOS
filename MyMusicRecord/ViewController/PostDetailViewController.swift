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
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomDivider: UITextView!
    @IBOutlet weak var topDivider: UITextView!
    
    var post: Posting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
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
    }

}
