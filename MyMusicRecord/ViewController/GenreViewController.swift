//
//  GenreViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/11.
//

import UIKit

class GenreViewController: UIViewController {
    @IBOutlet weak var titleTextView: UILabel!
    var genre: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextView.text = genre
    }

}
