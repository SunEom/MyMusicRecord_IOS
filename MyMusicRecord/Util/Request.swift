//
//  Request.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/21.
//

import Foundation
import Alamofire

class Request {
    static func getLogin() -> User? {
        var user: User? = nil
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
                
                user =  User(id: id, userId: userId, genres: genres, nickname: nickname, aboutMe: aboutMe, password: password)
                
            //통신실패
            case .failure(let error):
                print("error: \(String(describing: error.errorDescription))")
            }
        }
        return user
    }
}
