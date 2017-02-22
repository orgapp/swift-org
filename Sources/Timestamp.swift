//
//  Timestamp.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 8/01/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Timestamp {
    public let active: Bool
    public let date: Date
    public let repeater: String?
    
    static func from(string: String) -> Timestamp? {
        let markPattern = "\\+|\\+\\+|\\.\\+|-|--"
        let pattern = "^(<|\\[)(.+?)(?: (\(markPattern))(\\d+)([hdwmy])\\s*)?(>|])$"
        guard let m = string.trimmed.match(pattern) else {
            return nil
        }
        
        let formater = DateFormatter()
        let formats = [
            "yyyy-MM-dd EEE H:mm",
            "yyyy-MM-dd EEE",
        ]
        
        for format in formats {
            formater.dateFormat = format
            // It acts differently in Linux and !Linux env
            guard let date = formater.date(from: m[2]!) else { continue }
            let active = m[1]! == "<"
            
            var repeater: String? = nil
            if let mark = m[3], let value = m[4], let unit = m[5] {
                repeater = "\(mark)\(value)\(unit)"
            }
            let timestamp = Timestamp(active: active, date: date, repeater: repeater)
            return timestamp
        }
        return nil
    }
}
