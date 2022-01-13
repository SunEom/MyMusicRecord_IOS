//
//  GenreViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/11.
//

import UIKit
import Alamofire

class GenreViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var genre: String?
    var genrePostings = [Posting]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await requestHttp()
        }
        configureNavigationBar()
        configureCollectionView()
        addSampleContents()
        
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 25
        self.collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
     
    private func addSampleContents() {
        genrePostings.append(Posting(title: "Winter Flower", artist: "YounHa", genre: "K-POP", nickname: "Suneom", postBody: "Good..", createdDate: Date()))
        genrePostings.append(Posting(title: "I'MMA DO", artist: "YUMDDA", genre: "HIP-HOP", nickname: "Suneom", postBody: "Good!", createdDate: Date()))
        genrePostings.append(Posting(title: "Snowman", artist: "Sia", genre: "POP", nickname: "Suneom", postBody: "Good..😃", createdDate: Date()))
        genrePostings.append(Posting(title: "TWINTAIL20", artist: "D-Hack", genre: "HIP-HOP", nickname: "Suneom", postBody: "My favorite Song!", createdDate: Date()))
        genrePostings.append(Posting(title: "Have to", artist: "YounHa", genre: "K-POP", nickname: "Suneom", postBody: "Cool..", createdDate: Date()))
        collectionView.reloadData()
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        if let _ = self.navigationController?.navigationBar.items?[0].title {
            self.navigationController?.navigationBar.items?[0].title = "Home"
        }
    }
    
    private func requestHttp() async {
        guard let genre = genre else { return }
        await AF.request("\(Env.getServerURL())/search/genres/\(genre)").responseJSON() { response in
          switch response.result {
          case .success:
            if let data = try! response.result.get() as? [String: Any] {
                guard let postings = data["payload"] as? NSArray else { return }
            
                for posting in postings {
                    guard let posting = posting as? [String: Any] else { return }
                    guard let title = posting["title"] as? String else { return }
                    guard let artist = posting["artist"] as? String else { return }
                    guard let nickname = "Suneom" as? String else { return }
                    guard let genre = posting["genre"] as? String else { return }
                    guard let postBody = posting["post_body"] as? String else { return }
                    guard let created = posting["created_date"] as? String else { return }
                    guard let createdDate = Util.StringToDate(date: String(created.split(separator: "T")[0])) else { return }

                    self.genrePostings.append(Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, createdDate: createdDate))
                }

                self.collectionView.reloadData()
            }
          case .failure(let error):
            print("Error: \(error)")
            return
          }
        }
    }
}

extension GenreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genrePostings.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostingCell", for: indexPath) as? PostingCell else { return UICollectionViewCell() }
        
        let posting = self.genrePostings[indexPath.row]
        cell.titleLabel.text = posting.title
        cell.artistLabel.text = posting.artist
        cell.userLabel.text = posting.nickname
        cell.dateLabel.text = Util.DateToString(date: posting.createdDate)
        cell.imageView.image = UIImage(named: posting.genre)
        cell.imageView.sizeToFit()
        
        return cell
        
    }
}

extension GenreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width , height: ((UIScreen.main.bounds.width - 40)/360*200)+150
        )
    }
}
