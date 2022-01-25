//
//  CommentCell.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/14.
//

import UIKit
import Alamofire

class CommentCell: UICollectionViewCell {
    var comment: Comment?
    var navigationController: UINavigationController?
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var divider: UITextView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func tapEditButton(_ sender: Any) {
    }
    @IBAction func tapDeleteButton(_ sender: Any) {
        let alertController = UIAlertController(title: "주의", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)

        let cancelOption = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            guard let commentNum = self.comment?.commentNum else { return }
            AF.request("\(Env.getServerURL())/comment/\(commentNum)", method: .delete)
                .validate(statusCode: 200..<300)
                .responseJSON() { response in
                    switch response.result {
                    case .success(let value):
                        NotificationCenter.default.post(name: Notification.Name("CommentUpdated"), object: nil)
                        
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
        })
        let saveOption = UIAlertAction(title: "Cancel", style: .default)

        alertController.addAction(saveOption)
        alertController.addAction(cancelOption)
        self.navigationController?.present(alertController, animated: true, completion: nil)
        
    }
}
