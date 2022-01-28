//
//  SearchViewController.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/18.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var tapViewGesture: UITapGestureRecognizer!
    
    var resultPostings = [Posting]()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(responseUserInfo(_:)), name: NSNotification.Name("responseUserInfo"), object: nil)
        
        NotificationCenter.default.post(name: Notification.Name("requestUserInfo"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInNotification(_:)), name: NSNotification.Name("signIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInNotification(_:)), name: NSNotification.Name("logOut"), object: nil)
        
        configureCollectionView()
        configureSearchBar()
        configureViewController()
    }

    @objc func responseUserInfo(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func signInNotification(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func logOutNotification(_ notification: Notification){
        self.user = nil
    }

    
    private func configureViewController() {
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
    }
    
    private func configureCollectionView(){
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.collectionView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        self.searchBarSearchButtonClicked(self.searchBar)
        self.collectionView.refreshControl?.endRefreshing()
    }


}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultPostings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostingCell", for: indexPath) as? PostingCell else { return UICollectionViewCell() }
        
        let posting = resultPostings[indexPath.row]
        cell.titleLabel.text = posting.title
        cell.artistLabel.text = posting.artist
        cell.userLabel.text = posting.nickname
        cell.dateLabel.text = Util.DateToString(date: posting.createdDate)
        cell.imageView.image = UIImage(named: posting.genre)
        
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: ((UIScreen.main.bounds.width - 40)/360*200)+130)
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController else { return }
        viewController.post = self.resultPostings[indexPath.row]
        viewController.user = self.user
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        guard let keyword = searchBar.text else { return }
        
        if keyword == "" {
            return
        }
        
        
        
        AF.request("\(Env.getServerURL())/search?tl=\(keyword)", method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
                switch response.result
                {
                //통신성공
                case .success(let value):
                    guard let data = value as? [String: Any] else { return }
                    guard let postings = data["payload"] as? NSArray else { return }
                
                    self.resultPostings.removeAll()
                    
                    for posting in postings {
                        guard let posting = posting as? [String: Any] else { return }
                        guard let title = posting["title"] as? String else { return }
                        guard let artist = posting["artist"] as? String else { return }
                        guard let nickname = posting["nickname"] as? String else { return }
                        guard let genre = posting["genre"] as? String else { return }
                        guard let postBody = posting["post_body"] as? String else { return }
                        guard let postNum = posting["post_num"] as? Int else { return }
                        guard let rating = posting["rating"] as? Double else { return }
                        guard let writerId = posting["writer_id"] as? Int else { return }
                        guard let created = posting["created_date"] as? String else { return }
                        guard let createdDate = Util.StringToDate(date: String(created.split(separator: "T")[0])) else { return }

                        self.resultPostings.append(Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, postNum: postNum, rating: rating, writerId: writerId, createdDate: createdDate))
                    }

                    self.collectionView.reloadData()
                    
                //통신실패
                case .failure(let error):
                    print("error: \(String(describing: error.errorDescription))")
                }
            }
    }
    
}
