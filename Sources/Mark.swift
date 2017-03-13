//
//  Mark.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 13/03/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Mark: CustomStringConvertible {
  // MARK: properties
  let range: Range<String.Index>
  var name: String
  var marks = [Mark]()
  
  // MARK: init
  init(range _range: Range<String.Index>, name _name: String) {
    range = _range
    name = _name
  }
  
  init?(_ _name: String, marks: [Mark]) {
    if marks.isEmpty { return nil }
    name = _name
    range = marks.first!.range.lowerBound..<marks.last!.range.upperBound
  }
  
  // MARK: func
  mutating func include(_ mark: Mark) {
    marks.append(mark)
  }
  
  func value(on text: String) -> String {
    return text.substring(with: range)
  }
  
  subscript(_name: String) -> Mark? {
    get {
      return marks.first { mark in
        let n = mark.name[name.endIndex..<mark.name.endIndex]
        return n == _name
      }
    }
  }
  
  public var description: String {
    return "Mark(name: \(name))"
  }
}

extension String {
  func scope(under name: String) -> Bool {
    return self.hasPrefix(name) && self.characters.count > name.characters.count
  }
}
