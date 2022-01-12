//
//  Env.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/12.
//

import Foundation

class Env {
    static func getServerURL() -> String {
        if let url = ProcessInfo.processInfo.environment["SERVER_URL"] {
            return url
        }
        return ""
    }
}
