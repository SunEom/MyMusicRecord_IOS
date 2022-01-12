//
//  ViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/11.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var recentPostings: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await requestHttp()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        if let _ = self.navigationController?.navigationBar.items?[0].title {
            self.navigationController?.navigationBar.items?[0].title = "My Music Record"
        }
    }

    
    private func requestHttp() async {
        await AF.request("http://localhost:8000/post").responseJSON() { response in
          switch response.result {
          case .success:
            if let data = try! response.result.get() as? [String: Any] {
                guard let postings = data["payload"] as? NSArray else { return }
                self.recentPostings = postings
                print(self.recentPostings)
            }
          case .failure(let error):
            print("Error: \(error)")
            return
          }
        }
    }
}

