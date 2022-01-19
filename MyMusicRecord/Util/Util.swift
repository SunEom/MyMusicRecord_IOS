//
//  Util.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/14.
//

import Foundation
import UIKit

class Util {
    static func StringToDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date)
    }
    
    static func DateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "yyyy. MM. dd. (EEEEE)"
        return dateFormatter.string(from: date)
    }
    
    static func createSimpleAlert(_ viewController: UIViewController, title: String, message: String, completion: (()->Void)? = nil, navCon: UINavigationController? = nil ,toRoot: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        if toRoot {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: navCon != nil ? {(action) in
                navCon?.popToRootViewController(animated: true)} : nil))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: navCon != nil ? {(action) in
                navCon?.popViewController(animated: true)} : nil))
        }
        
        viewController.present(alert, animated: true, completion: completion)
    }
}
