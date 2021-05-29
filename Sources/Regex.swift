//
//  Regex.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

#if !os(Linux)
public typealias RegularExpression = NSRegularExpression
public typealias TextCheckingResult = NSTextCheckingResult
#else
    extension TextCheckingResult {
        func rangeAt(_ idx: Int) -> NSRange {
            return range(at: idx)
        }
    }
#endif

var expressions = [String: RegularExpression]()

public extension String {

    /// Cache regex (for performance and resource sake)
    ///
    /// - Parameters:
    ///   - regex: regex pattern
    ///   - options: options
    /// - Returns: the regex
    private func getExpression(_ regex: String, options: RegularExpression.Options) -> RegularExpression {
        let expression: RegularExpression
        if let exists = expressions[regex] {
            expression = exists
        } else {
            expression = try! RegularExpression(pattern: regex, options: options)
            expressions[regex] = expression
        }
        return expression
    }

    private func getMatches(_ match: TextCheckingResult) -> [String?] {
        var matches = [String?]()
        switch match.numberOfRanges {
        case 0:
            return []
        case let n where n > 0:
            for i in 0..<n {
                let r = match.range(at: i)
                matches.append(r.length > 0 ? NSString(string: self).substring(with: r) : nil)
            }
        default:
            return []
        }
        return matches
    }

    func match(_ regex: String, options: RegularExpression.Options = []) -> [String?]? {
        let expression = self.getExpression(regex, options: options)

        if let match = expression.firstMatch(in: self, options: [], range: NSMakeRange(0, self.utf16.count)) {
            return getMatches(match)
        }
        return nil
    }

    func matchSplit(_ regex: String, options: RegularExpression.Options) -> [String] {
        let expression = self.getExpression(regex, options: options)
        let matches = expression.matches(in: self, options: [], range: NSMakeRange(0, self.utf16.count))
        var splitted = [String]()
        var cursor = 0
        for m in matches {
            if m.range.location > cursor {
                splitted.append(self.substring(with: self.index(self.startIndex, offsetBy: cursor)..<self.index(self.startIndex, offsetBy: m.range.location)))
            }
            splitted.append(NSString(string: self).substring(with: m.range))
            cursor = (m.range.toRange()?.upperBound)! + 1
        }
        if cursor <= self.count {
            splitted.append(self.substring(with: self.index(self.startIndex, offsetBy: cursor)..<self.endIndex))
        }
        return splitted
    }

    func tryMatch(_ regex: String,
                        options: RegularExpression.Options = [],
                        match: ([String?]) -> Void,
                        or: (String) -> Void) {
        let expression = self.getExpression(regex, options: options)
        let matches = expression.matches(in: self, options: [], range: NSMakeRange(0, self.utf16.count))
        var cursor = 0
        for m in matches {
            if m.range.location > cursor {
                or(self.substring(with: self.index(self.startIndex, offsetBy: cursor)..<self.index(self.startIndex, offsetBy: m.range.location)))
            }
            match(getMatches(m))
            cursor = (m.range.toRange()?.upperBound)!
        }
        if cursor < self.count {
            or(self.substring(with: self.index(self.startIndex, offsetBy: cursor)..<self.endIndex))
        }
    }
}
