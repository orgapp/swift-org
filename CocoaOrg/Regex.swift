//
//  Regex.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

var expressions = [String: NSRegularExpression]()
public extension String {
    func getExpression(_ regex: String, options: NSRegularExpression.Options) -> NSRegularExpression {
        let expression: NSRegularExpression
        if let exists = expressions[regex] {
            expression = exists
        } else {
            expression = try! NSRegularExpression(pattern: regex, options: options)
            expressions[regex] = expression
        }
        return expression
    }
    
    func getMatches(_ match: NSTextCheckingResult) -> [String?] {
        var matches = [String?]()
        switch match.numberOfRanges {
        case 0:
            return []
        case let n where n > 0:
            for i in 0..<n {
                let r = match.rangeAt(i)
                matches.append(r.length > 0 ? (self as NSString).substring(with: r) : nil)
            }
        default:
            return []
        }
        return matches
    }
    
    public func match(_ regex: String, options: NSRegularExpression.Options = []) -> [String?]? {
        let expression = self.getExpression(regex, options: options)
        
        if let match = expression.firstMatch(in: self, options: [], range: NSMakeRange(0, self.utf16.count)) {
            return getMatches(match)
        }
        return nil
    }
    
    public func matchSplit(_ regex: String, options: NSRegularExpression.Options) -> [String] {
        let expression = self.getExpression(regex, options: options)
        let matches = expression.matches(in: self, options: [], range: NSMakeRange(0, self.utf16.count))
        var splitted = [String]()
        var cursor = 0
        for m in matches {
            if m.range.location > cursor {
                splitted.append(self.substring(with: self.characters.index(self.startIndex, offsetBy: cursor)..<self.characters.index(self.startIndex, offsetBy: m.range.location)))
            }
            splitted.append((self as NSString).substring(with: m.range))
            cursor = (m.range.toRange()?.upperBound)! + 1
        }
        if cursor <= self.characters.count {
            splitted.append(self.substring(with: self.characters.index(self.startIndex, offsetBy: cursor)..<self.endIndex))
        }
        return splitted
    }
    
    public func tryMatch(_ regex: String,
                        options: NSRegularExpression.Options = [],
                        match: ([String?]) -> Void,
                        or: (String) -> Void) {
        let expression = self.getExpression(regex, options: options)
        let matches = expression.matches(in: self, options: [], range: NSMakeRange(0, self.utf16.count))
        var cursor = 0
        for m in matches {
            if m.range.location > cursor {
                or(self.substring(with: self.characters.index(self.startIndex, offsetBy: cursor)..<self.characters.index(self.startIndex, offsetBy: m.range.location)))
            }
            match(getMatches(m))
            cursor = (m.range.toRange()?.upperBound)! + 1
        }
        if cursor <= self.characters.count {
            or(self.substring(with: self.characters.index(self.startIndex, offsetBy: cursor)..<self.endIndex))
        }
    }
}
