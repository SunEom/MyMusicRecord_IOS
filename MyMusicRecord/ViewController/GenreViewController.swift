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
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await requestHttp()
        }
     
        NotificationCenter.default.addObserver(self, selector: #selector(responseUserInfo(_:)), name: NSNotification.Name("responseUserInfo"), object: nil)
        
        NotificationCenter.default.post(name: Notification.Name("requestUserInfo"), object: nil, userInfo: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInNotification(_:)), name: NSNotification.Name("signIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOutNotification(_:)), name: NSNotification.Name("logOut"), object: nil)
        
        configureNavigationBar()
        configureCollectionView()
    }
    
    @objc func logOutNotification(_ notification: Notification){
        self.user = nil
    }
    
    @objc func responseUserInfo(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func signInNotification(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        Task {
            await self.requestHttp()
        }
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 10
        self.collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.collectionView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    private func configureNavigationBar() {
        if let _ = self.navigationController?.navigationBar.items?[0].title {
            self.navigationController?.navigationBar.items?[0].title = "Home"
        }
    }
    
    private func requestHttp() async {
        guard let genre = genre else { return }
        await AF.request("\(Env.getServerURL())/search/genres/\(genre.split(separator: " ")[0])").responseJSON() { response in
          switch response.result {
          case .success:
            if let data = try! response.result.get() as? [String: Any] {
                guard let postings = data["payload"] as? NSArray else { return }
            
                self.genrePostings.removeAll()
                
                for posting in postings {
                    guard let posting = posting as? [String: Any] else { return }
                    guard let title = posting["title"] as? String else { return }
                    guard let artist = posting["artist"] as? String else { return }
                    guard let nickname = "Suneom" as? String else { return }
                    guard let genre = posting["genre"] as? String else { return }
                    guard let postBody = posting["post_body"] as? String else { return }
                    guard let postNum = posting["post_num"] as? Int else { return }
                    guard let writerId = posting["writer_id"] as? Int else { return }
                    guard let rating = posting["rating"] as? Double else { return }
                    guard let created = posting["created_date"] as? String else { return }
                    guard let createdDate = Util.StringToDate(date: String(created.split(separator: "T")[0])) else { return }

                    self.genrePostings.append(Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, postNum: postNum,  rating: rating, writerId: writerId, createdDate: createdDate))
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
        return CGSize(width: UIScreen.main.bounds.width , height: ((UIScreen.main.bounds.width - 40)/360*200)+130)
    }
}

extension GenreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController else { return }
        viewController.post = self.genrePostings[indexPath.row]
        viewController.user = self.user
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
