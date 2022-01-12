//
//  ViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/11.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var recentPostings = [Posting]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await self.requestHttp()
        }
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 25
        self.collectionView.collectionViewLayout = layout
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func configureNavigationBar() {
        if let _ = self.navigationController?.navigationBar.items?[0].title {
            self.navigationController?.navigationBar.items?[0].title = "My Music Record"
        }
    }

    
    private func requestHttp() async {
        await AF.request("\(Env.getServerURL())/post").responseJSON() { response in
          switch response.result {
          case .success:
            if let data = try! response.result.get() as? [String: Any] {
                guard let postings = data["payload"] as? NSArray else { return }
    
                for posting in postings {
                    guard let posting = posting as? [String: Any] else { return }
                    guard let title = posting["title"] as? String else { return }
                    guard let artist = posting["artist"] as? String else { return }
                    guard let nickname = posting["nickname"] as? String else { return }
                    guard let genre = posting["genre"] as? String else { return }
                    guard let postBody = posting["post_body"] as? String else { return }
                    guard let created = posting["created_date"] as? String else { return }
                    guard let createdDate = self.StringToDate(date: String(created.split(separator: "T")[0])) else { return }
                                                              
                    self.recentPostings.append(Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, createdDate: createdDate))
                }
                
                self.collectionView.reloadData()
            }
          case .failure(let error):
            print("Error: \(error)")
            return
          }
        }
    }
    
    private func StringToDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date)
    }
    
    private func DateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        return dateFormatter.string(from: date)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RecentHeaderView", for: indexPath)
            return headerView
        default:
            return UICollectionReusableView()
            
        }

        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40 , height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentPostings.count
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostingCell", for: indexPath) as? PostingCell else { return  UICollectionViewCell() }
        let posting = recentPostings[indexPath.row]
        cell.titleLabel.text = posting.title
        cell.artistLabel.text = posting.artist
        cell.userLabel.text = posting.nickname
        cell.dateLabel.text = DateToString(date: posting.createdDate)
        cell.imageView.image = UIImage(named: posting.genre)
        return cell
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40 , height: ((UIScreen.main.bounds.width - 40)/360*200)+135)
    }
}

