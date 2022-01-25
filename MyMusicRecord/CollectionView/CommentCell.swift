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
    @IBOutlet weak var contentsTextField: UITextField!
    @IBOutlet weak var divider: UITextView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func tapEditButton(_ sender: UIButton) {
        if self.contentsTextField.isEnabled {
            self.contentsTextField.isEnabled = false
            self.contentsTextField.borderStyle = .none
            sender.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            
            guard let comment = self.comment?.contents else { return }
            guard let commentNum = self.comment?.commentNum else { return }
            guard let contents = self.contentsTextField.text else { return }
            if comment != contents {
                let PARAM: Parameters = [
                    "comment_num": commentNum,
                    "comment": contents
                ]
                
                AF.request("\(Env.getServerURL())/comment/update", method: .patch ,parameters: PARAM)
                    .validate(statusCode: 200..<300)
                    .responseJSON() { response in
                        switch response.result  {
                        case .success(let value):
                            self.comment?.contents = contents
                            
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
            }
        } else {
            self.contentsTextField.isEnabled = true
            self.contentsTextField.borderStyle = .roundedRect
            sender.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        }
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
