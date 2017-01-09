//
//  Timestamp.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 8/01/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Timestamp {
    let active: Bool
    let date: Date
    let repeater: String?
    
    static func from(string: String) -> Timestamp? {
        let markPattern = "\\+|\\+\\+|\\.\\+|-|--"
        let pattern = "^(<|\\[)(.+?)(?: (\(markPattern))(\\d+)([hdwmy])\\s*)?(>|])$"
        guard let m = string.match(pattern) else {
            print("'\(string)' doesn't match.")
            return nil
        }
        
        print("match: \(m)")
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd EEE H:mm"
        guard let date = formater.date(from: m[2]!) else { return nil }
        let active = m[1]! == "<"
        
        var repeater: String? = nil
        if let mark = m[3], let value = m[4], let unit = m[5] {
            repeater = "\(mark)\(value)\(unit)"
        }
        let timestamp = Timestamp(active: active, date: date, repeater: repeater)
        return timestamp
    }
}
