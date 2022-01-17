//
//  MyPageViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/17.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDiviers()
        configureTitleLabels()
        }
    
    private func configureDiviers(){
        nicknameDivider.layer.borderColor = UIColor.gray.cgColor
        aboutMeDivider.layer.borderColor = UIColor.gray.cgColor
        preferGenreDivider.layer.borderColor = UIColor.gray.cgColor
        
        nicknameDivider.layer.borderWidth = 1.0
        aboutMeDivider.layer.borderWidth = 1.0
        preferGenreDivider.layer.borderWidth = 1.0
    }
    
    private func configureTitleLabels() {
        nicknameTitleLabel.sizeToFit()
        aboutmeTitleLabel.sizeToFit()
        preferGenreTitleLabel.sizeToFit()
    }
    
}
