//
//  Util.swift
//  MyMusicRecord
//
//  Created by 엄태양 on 2022/01/14.
//

import Foundation

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
}
