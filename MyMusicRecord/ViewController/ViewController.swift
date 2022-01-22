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
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInNotification(_:)), name: NSNotification.Name("signIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOutNotification(_:)), name: NSNotification.Name("logOut"), object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeProfileNotification(_:)),
            name: Notification.Name("changeProfile"),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(requestUserInfoNotification(_:)),
            name: Notification.Name("requestUserInfo"),
            object: nil)

        
        self.loadUserData()
        self.requestHttp()
    
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
    }
    
    private func loadUserData(){
        let userDefaults = UserDefaults.standard
        guard let signInInfo = userDefaults.object(forKey: "signInInfo") as? [String: String] else { return }
        guard let id = signInInfo["id"] else { return }
        guard let password = signInInfo["password"] else { return }
        
        let PARAM: Parameters = [
            "id": id,
            "password": password
        ]
        
        self.requestPostSigniIn(PARAM: PARAM)
        
    }
    
    @objc func logOutNotification(_ notification: Notification){
        self.user = nil
    }
    
    @objc func requestUserInfoNotification(_ notification: Notification){
        NotificationCenter.default.post(name: Notification.Name("responseUserInfo"), object: self.user)
    }
    
    @objc func signInNotification(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func changeProfileNotification(_ notification: Notification){
        guard let user = notification.object as? User else { return }
        self.user = user
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        self.recentPostings.removeAll()
        self.requestHttp()
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    private func requestPostSigniIn(PARAM: Parameters) {
        AF.request("\(Env.getServerURL())/auth/login", method: .post, parameters: PARAM)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                guard let data = value as? [String: Any] else { return }
                guard let userData = data["payload"] as? [String: Any] else { return }
    
                guard let id = userData["id"] as? Int else { return }
                guard let userId = userData["user_id"] as? String else { return }
                guard let genres = userData["genres"] as? NSArray else { return }
                guard let nickname = userData["nickname"] as? String else { return }
                guard let aboutMe = userData["about_me"] as? String? else { return }
                guard let password = userData["password"] as? String else { return }
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("signIn"),
                    object: User(id: id, userId: userId, genres: genres, nickname: nickname, aboutMe: aboutMe, password: password),
                    userInfo: nil)
            
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        self.collectionView.collectionViewLayout = layout
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.collectionView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    private func configureNavigationBar() {
        if let _ = self.navigationController?.navigationBar.items?[0].title {
            self.navigationController?.navigationBar.items?[0].title = "My Music Record"
        }
    }

    
    private func requestHttp() {
        AF.request("\(Env.getServerURL())/post").responseJSON() { response in
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
                    guard let postNum = posting["post_num"] as? Int else { return }
                    guard let writerId = posting["writer_id"] as? Int else { return }
                    guard let createdDate = Util.StringToDate(date: String(created.split(separator: "T")[0])) else { return }
                                                              
                    self.recentPostings.append(Posting(title: title, artist: artist, genre: genre, nickname: nickname, postBody: postBody, postNum: postNum, writerId: writerId, createdDate: createdDate))
                }
                
                self.collectionView.reloadData()
            }
          case .failure(let error):
            print("Error: \(error)")
            return
          }
        }
    }
    
    private func requestGetLogin() async {
        AF.request("\(Env.getServerURL())/auth/login", method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON() { response in
            switch response.result
            {
            //통신성공
            case .success(let value):
                guard let data = value as? [String: Any] else { return }
                guard let userData = data["payload"] as? [String: Any] else { return }
    
                guard let id = userData["id"] as? Int else { return }
                guard let userId = userData["user_id"] as? String else { return }
                guard let genres = userData["genres"] as? NSArray else { return }
                guard let nickname = userData["nickname"] as? String else { return }
                guard let aboutMe = userData["about_me"] as? String? else { return }
                guard let password = userData["password"] as? String else { return }
                
                self.user = User(id: id, userId: userId, genres: genres, nickname: nickname, aboutMe: aboutMe, password: password)
                
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
    }
    
    @IBAction func tapUserButton(_ sender: Any) {
        Task{
            await requestGetLogin()
        }
        
        if let user = self.user {
            guard let viewContainer = self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else { return }
            viewContainer.user = user
            self.navigationController?.pushViewController(viewContainer, animated: true)
        } else {
            guard let viewContainer = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else { return }
            self.navigationController?.pushViewController(viewContainer, animated: true)
        }
    
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
        cell.dateLabel.text = Util.DateToString(date: posting.createdDate)
        cell.imageView.image = UIImage(named: posting.genre)
        return cell
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width , height: ((UIScreen.main.bounds.width - 40)/360*200)+130)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController else { return }
        viewController.post = recentPostings[indexPath.row]
        viewController.user = self.user
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

