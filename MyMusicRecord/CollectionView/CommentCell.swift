//
//  CommentCell.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/14.
//

import UIKit

class CommentCell: UICollectionViewCell {
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var divider: UITextView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
}
