//
//  String.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 15/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public func multiline(_ x: String...) -> String {
  return x.joined(separator: "\n")
}

extension String {
  var lines: [String] { return self.components(separatedBy: CharacterSet.newlines) }
  var trimmed: String {
    return self.trimmingCharacters(in: CharacterSet.whitespaces)
  }
  
  func indent(_ n: Int) -> String {
    return "\(String(repeating: " ", count: n))\(self)"
  }
  
  func nsRange(from range: Range<String.Index>) -> NSRange {
    let from = range.lowerBound.samePosition(in: utf16)
    let to = range.upperBound.samePosition(in: utf16)
    return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                   length: utf16.distance(from: from, to: to))
  }
  
  func range(from nsRange: NSRange) -> Range<String.Index>? {
    guard
      let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
      let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
      let from = from16.samePosition(in: self),
      let to = to16.samePosition(in: self)
      else { return nil }
    return from ..< to
  }  
}

func length(_ text: String?) -> Int {
  return (text ?? "").characters.count
}
