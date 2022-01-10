//
//  SidebarNavigationViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/11.
//

import UIKit

class SidebarNavigationViewController: UIViewController {
    @IBOutlet weak var navigationHeader: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    @IBAction func tapGenreButton(_ sender: UIButton) {
        guard let genreViewController = self.storyboard?.instantiateViewController(withIdentifier: "GenreViewController") as? GenreViewController else { return }
        genreViewController.genre = sender.titleLabel!.text
        self.navigationController?.pushViewController(genreViewController, animated: true)
    }
}
